require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui.rb'


require File.dirname(__FILE__) + '/../lib/config.rb'
# require ENV['TM_BUNDLE_SUPPORT'] + '/lib/config.rb'

puts 'This command is not currently functional!'

# 
# items = Config.environments
# items.push({'separator'=>1})
# items.push({'title'=>'Edit Environments...', 'edit'=>true})
# 
# t = TextMate::UI.menu(items)
# puts t.inspect