module Webbynode::Engines
  module Engine
    def self.included(base)
      base.send(:attr_accessor, :io)
    end
  end
end