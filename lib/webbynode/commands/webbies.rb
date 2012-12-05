module Webbynode::Commands
  class Webbies < Webbynode::Command
    summary "Lists the Webbies you currently own"
    add_alias "list"
    
    def execute
      puts "Fetching list of your Webbies..."
      puts ""

      table(%w(Name IP Node Plan Status), %w(30 15 11 15 30)) { api.webbies }
    end

    def table(cols, sizes)
      header =  "  "
      cols.each_with_index do |col, i|
        #header << col.ljust(sizes[i].to_i).bright.underline
        header << col.ljust(sizes[i].to_i).bright.underline
        header << " "
      end

      puts header
      spinner { yield }.each_pair do |name, item|
        str = "  "
        cols.each_with_index do |col, i|
          str << item.send(col.downcase).ljust(sizes[i].to_i+1)
        end
        puts str
      end

      puts ""
    end
  end
end