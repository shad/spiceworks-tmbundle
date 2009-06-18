require 'uri'
require 'net/http'
require 'yaml'

# Get the contents of the file and parse out the GUID
content = nil
File.open(ENV['TM_FILEPATH']) do |f|
  content = f.read
end
guid = content[/\@guid\s+([\w\d-]+)$/, 1]

name = content[/\@name\s+(.+)$/, 1]
description = content[/\@description\s+(.+)$/, 1]
version = content[/\@version\s+(.+)$/, 1]

config_file = File.join(File.dirname(__FILE__), 'config.yml')
config = File.exists?(config_file) ? File.open(config_file) { |f| YAML::load(f) } : {'login' => {}}
url = URI.parse(config['login']['url'] || 'http://localhost:9675/')
user = config['login']['user']
password = config['login']['pass']

save_res = nil

Net::HTTP.new(url.host, url.port).start do |http|
  login_page_get = Net::HTTP::Get.new('/login')
  login_page_res = http.request(login_page_get)
  md = login_page_res.body.match(/input.*name=.*authenticity_token.*value=[\'\"]([^\'\"]+)[\'\"]/)
  
  auth_token = md[1]
    
  # Post to log the user in.
  login_post = Net::HTTP::Post.new('/account/login')
  login_post.set_form_data( {'user[password]'=>password, 'user[email]'=>user, 'authenticity_token'=>auth_token} )
  login_post['Cookie'] = login_page_res['Set-Cookie']
  login_res = http.request(login_post)
  
  if login_res.is_a?(Net::HTTPSuccess)
    puts "Unauthorized user, please check your login and password. You might have to setup your config.yml file in this bundle's Support/bin directory"
    break
  end
    
  # put the new file up on the server
  save_put = Net::HTTP::Put.new("/settings/plugins/#{guid}")
  save_put.set_form_data({'plugin[content]'=>content, 'authenticity_token'=>auth_token})
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
    create_post.set_form_data({'authenticity_token'=>auth_token, 'data'=>{:guid=>guid, :name=>name, :description=>description, :version=>version, :content=>content}.to_yaml})
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


