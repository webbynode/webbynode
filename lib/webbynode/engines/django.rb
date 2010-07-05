module Webbynode::Engines
  class Django
    include Engine
    set_name "Django"
    git_excludes 'settings.py', '*.pyc', '*.pyo', 'docs/_build'
    
    def prepare
      unless io.file_exists?('settings.py')
        raise Webbynode::Command::CommandError, 
          "Couldn't create the settings template because settings.py was not found. Please check and try again."
      end
      
      unless io.file_exists?('settings.template.py')
        io.log 'Creating settings.template.py from your settings.py...'
        io.copy_file 'settings.py', 'settings.template.py'

        change_templates

        change_settings({
          'ENGINE' => '@app_engine@', 
          'NAME' => '@app_name@',                      
          'USER' => '@app_name@',                      
          'PASSWORD' => '@app_pwd@',                  
          'HOST' => '@db_host@',                      
          'PORT' => '@db_port@',
        })
      end
    end
    
    def change_settings(settings)
      settings.each_pair do |k,v|
        io.sed 'settings.template.py', /'#{k}': '[^ ,]*'/, "'#{k}': '#{v}'"
      end
    end
    
    def change_templates
      io.sed 'settings.template.py', /TEMPLATE_DIRS = \(/, "TEMPLATE_DIRS = (\n    '@app_dir@/templates'"
    end
  end
end