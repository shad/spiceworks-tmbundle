require 'uri'
require 'net/http'
require 'yaml'

# Get the contents of the file and parse out the GUID
content = nil
File.open(ENV['TM_FILEPATH']) do |f|
  content = f.read
end
guid = content[/\@guid\s+([\w\d-]+)$/, 1]

# use for development
server_name = content[/\@server\s+(.+)$/, 1]
user = content[/\@user\s+(.+)$/, 1]
password = content[/\@password\s+(.+)$/, 1]

name = content[/\@name\s+(.+)$/, 1]
description = content[/\@description\s+(.+)$/, 1]
version = content[/\@version\s+(.+)$/, 1]



url ||= URI.parse(server_name || ENV['SPICEWORKS_SERVER'] || "http://localhost:9675")
password ||= ENV['SPICEWORKS_PASSWORD']||'okokok'
user ||= ENV['SPICEWORKS_USER'] ||'shad@spiceworks.com'

save_res = nil

Net::HTTP.new(url.host, url.port).start do |http| 
  # Post to log the user in.
  login_post = Net::HTTP::Post.new('/account/login')
  login_post.set_form_data( {'user[password]'=>password, 'user[email]'=>user} )
  login_res = http.request(login_post)

  # put the new file up on the server
  save_put = Net::HTTP::Put.new("/settings/plugins/#{guid}")
  save_put.set_form_data({'plugin[content]'=>content})
  save_put['Cookie'] = login_res['Set-Cookie']
  save_put['Accept'] = 'text/javascript'
  save_res = http.request(save_put)

  case save_res
  when Net::HTTPSuccess
    puts "Published Plugin to #{url}"
  when Net::HTTPRedirection
    puts "redirected? #{save_res.header['location']}"
  when Net::HTTPNotAcceptable
    
    # put the new file up on the server
    create_post = Net::HTTP::Post.new("/settings/plugins/import")
    create_post.set_form_data({'data'=>{:guid=>guid, :name=>name, :description=>description, :version=>version, :content=>content}.to_yaml})
    create_post['Cookie'] = login_res['Set-Cookie']
    create_post['Accept'] = 'text/javascript'
    create_res = http.request(create_post)
    
    case create_res
    when Net::HTTPRedirection
      http.get("/settings/plugins/#{guid}/edit?make_local=true")
      puts "Imported Plugin to #{url}"
    end
    
  else
    puts "There was a problem saving: #{save_res.inspect}"
  end

end


