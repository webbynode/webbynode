module Webbynode
  module Updater
    def check_for_updates
      updated = remote_executor.exec(<<-EOS, false, true)
      if [ ! -f /var/webbynode/update_rapp ]; then
        cd /var/webbynode
        wget http://repo.webbynode.com/rapidapps/update_rapp
        chmod +x update_rapp
        ln -s -f /var/webbynode/update_rapp /usr/bin/update_rapp
      fi

      /var/webbynode/update_rapp
      if [ $? -eq 1 ]; then exit 1; fi
      EOS
    
      updated == 1
    end
  end
end