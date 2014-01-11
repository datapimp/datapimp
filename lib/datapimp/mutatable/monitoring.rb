module Datapimp
  module Mutatable
    module Monitoring
      extend ActiveSupport::Concern

      def mutations_monitor
        self.class.mutations_monitor
      end

      def monitor_mutations_request
        mutations_monitor.monitor(self)
      end

      included do
        before_filter :monitor_mutations_request
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

      def monitor(request_instance)
        # TODO
        # Implement
      end
    end
  end
end
