module Webbynode::Commands
  class Config < Webbynode::Command
    attr_writer :path
    add_alias "vars"

    summary "Manages the configuration variables for your application"
    parameter :action, String, "set or remove",
      required: false, validate: {in: ["set", "remove"]}
    parameter :name, String, "config var name",
      required: false
    parameter :value, String, "config var value",
      required: false

    def initialize(*args)
      super
    end

    def execute
      @action = param(:action) || "list"
      @name = param(:name)
      @value = param(:value)
      @path = "/#{pushand.parse_remote_app_name}"

      send("#{@action}_command")
    end

    def list_command
      vars = parse_vars(@path)
      vars.each_pair do |key, value|
        io.log "#{key}=#{value}"
      end
    end

    def set_command
      missing = []
      missing << "name" if @name.nil?
      missing << "value" if @value.nil?

      if missing.any?
        io.log "Missing #{missing.join(" and ")}"
        io.log "Use: webbynode config set [name] [value]"
        return
      end

      set_var(@name, @value)
    end

    def remove_command
      if @name.nil?
        io.log "Missing name"
        io.log "Use: webbynode config remove [name]"
        return
      end

      unset_var(@name)
    end

    def set_var(name, value)
      remote_executor.exec <<-EOS
dir="/var/webbynode/env#{@path}"
mkdir -p $dir
echo "#{value}" > $dir/#{name}
EOS
      list_command
    end

    def unset_var(name)
      remote_executor.exec <<-EOS
dir="/var/webbynode/env#{@path}"
mkdir -p $dir
rm $dir/#{name}
EOS
      list_command
    end

    def parse_vars(*paths)
      vars={}
      paths.each do |path|
        list_vars(path).split("\n").each do |line|
          key, value = line.split("=")
          vars[key] = value
        end
      end
      vars
    end

    def list_vars(path)
      remote_executor.exec <<-EOS
dir="/var/webbynode/env#{path}"

if [ ! -d $dir ]; then
  exit 0
fi

if ! ls -A $dir/* > /dev/null 2>&1; then
  exit 0
fi

cd $dir

for f in *; do
   if [ ! -d $f ]; then
      contents=`cat $f`
      [ -z $contents ] || echo "$f=$contents"
   fi
done
EOS
    end
  end
end
