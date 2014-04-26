module Datapimp
  module Documentation
    class Endpoint
      def self.call(env)
        request = Rack::Request.new(env)
        binding.pry
      end
    end
  end
end
