require 'yaml'

module Config
  
  DEFAULTS =  {'environments' => 
                  [ {'title'=>'Development',
                     'user'=>'yourusername', 
                     'pass'=>'yourpassword', 
                     'url'=>'http://localhost'},
                    {'title'=>'Production',
                      'user'=>'yourusername', 
                      'pass'=>'yourpassword', 
                      'url'=>'http://production_server'}]
              }
  CONFIG_FILE = File.join(File.dirname(ENV['TM_FILEPATH']), 'swconf')
              
              
  def self.file
    CONFIG_FILE
  end
  def self.config

    if !File.exists?(CONFIG_FILE)
      File.open( CONFIG_FILE, 'w' ) do |out|
        YAML.dump( DEFAULTS, out )
      end      
    end
    
    File.open(CONFIG_FILE) { |f| YAML::load(f) }
  end
  
  def self.environments
    self.config['environments']
  end
  
  def self.environments=(environments)
    config = self.config
    config['environments'] = environments
    
    File.open( CONFIG_FILE, 'w' ) do |out|
      YAML.dump( config, out )
    end
  end
end