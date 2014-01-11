module Datapimp
  module Mutatable
    module Monitoring
      extend ActiveSupport::Concern

      def mutations_monitor
        self.class.mutations_monitor
      end

      module ClassMethods
        def mutations_monitor
          @mutations_monitor ||= Datapimp::Mutatable::Monitor.new(self)
        end
      end
    end

    class Monitor
      attr_reader :id

      include Redis::Objects

      def initialize(controller_class)
        @id = controller_class.to_s + ':' + ::Rails.env
      end
    end
  end
end
