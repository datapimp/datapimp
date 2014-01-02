module Datapimp
  module Clients
    extend ActiveSupport::Autoload

    autoload :Github
    autoload :Amazon

    # Wrote this before adding autoload
    def self.load_all
      clients = Dir.glob(File.join(File.dirname(__FILE__),'clients') + '/*.rb')
      clients.each {|f| require(f) }
    end
  end
end
