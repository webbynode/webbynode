module Webbynode

  class Notify
    
    TITLE       = "Webbynode"
    IMAGE_PATH  = File.join(File.dirname(__FILE__), '..', '..', 'assets', 'webbynode.png')
    
    def self.message(message)
      if self.installed? and !$testing
        message = message.gsub(/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]/, "")
        %x(growlnotify -t "#{TITLE}" -m "#{message}" --image "#{IMAGE_PATH}" 2>/dev/null)
      end
    end
    
    def self.installed?
      @installed ||= Io.new.exec_in_path?("growlnotify")
    end
    
  end
end