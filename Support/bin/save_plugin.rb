require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui.rb'

require 'uri'
require 'net/http'
require 'yaml'

require ENV['TM_BUNDLE_SUPPORT'] + '/lib/config.rb'

begin
  
  # Get the contents of the file and parse out the GUID
  content = nil
  current_file = File.new(ENV['TM_FILEPATH'])

  File.open(ENV['TM_FILEPATH']) do |f|
    content = f.read
  end

  #### PARAMETERS #####
  # parse the parameters
  guid = content[/\@guid\s+([\w\d-]+)$/, 1]
  name = content[/\@name\s+(.+)$/, 1]
  description = content[/\@description\s+(.+)$/, 1]
  version = content[/\@version\s+(.+)$/, 1]


  items = Config.environments
  items.push({'separator'=>1})
  items.push({'title'=>'Edit Environments...', 'edit'=>true})

  deploy_to = TextMate::UI.menu(items)
  
  if deploy_to && deploy_to['edit']
    TextMate.go_to(:file=>Config.file)
  elsif !deploy_to.nil?
    
    url = URI.parse(deploy_to['url'])
    user = deploy_to['user']
    password = deploy_to['pass']
    
    ##### PERFORM THE REQUESTS TO SAVE #####
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
        puts "Unauthorized user, please check your login and password."
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
        puts "Published Plugin to #{deploy_to['title']}"
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
          puts "Imported Plugin to #{deploy_to['title']}"
        end

      else
        puts "There was a problem saving to #{deploy_to['title']}: #{save_res.inspect}"
      end

    end
  end

rescue Errno::ECONNREFUSED => e
  puts "Connection Refused: Most likely, your server is not running or you have the wrong server address or port."
rescue
  puts "#{$!.message}"
end



