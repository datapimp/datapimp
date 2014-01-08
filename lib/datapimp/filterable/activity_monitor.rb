require 'set'

module Datapimp::Filterable
  module ActivityMonitoring
    extend ActiveSupport::Concern

    mattr_accessor :_controllers

    def self.controllers
      _controllers.map {|s| s.first }.map(&:constantize)
    end

    def self._controllers
      @@controllers ||= Set.new
    end

    def activity_monitor
      self.class.activity_monitor
    end

    module ClassMethods
      def monitors_filterable_activity *args
        options = args.extract_options!
        on = options.fetch(:on, nil) || options.fetch(:only, nil)
        on ||= [:show,:index]
        on = on - options.fetch(:except, [])

        ActivityMonitoring._controllers << [self.to_s,on]
        activity_monitor.monitor_actions(*on)
      end

      def activity_monitor
        @activity_monitor ||= Datapimp::Filterable::ActivityMonitor.setup_monitoring_on(self)
      end

      def activity_monitor_report
        activity_monitor.try :report
      end
    end
  end

  class ActivityMonitor
    include Redis::Objects

    self.redis = Datapimp.config.redis_connection(:activity_monitoring)

    def self.setup_monitoring_on(filterable_controller_class)
      filterable_controller_class.send(:include, MonitoredActions)
      new(filterable_controller_class)
    end

    def initialize(filterable_controller_class)
      @klass = filterable_controller_class.to_s.underscore
      @actions = Set.new
    end

    def id
      "activity_monitor:#{ Rails.env }:#{ @klass }"
    end

    def monitor_actions *actions
      options = actions.extract_options!
      limit = options.fetch(:limit, 25)

      actions.each do |action_name|
        @actions << action_name
        self.class.send(:list, "#{ action_name }_requests", :maxlength => limit, :marshal => false)
      end
    end

    def activity_tracker_for(action)
      @activity_tracker = self.send("#{ action }_requests")
    end

    def activity_for(action)
      activity_tracker_for(action).map {|j| JSON.parse(j) }
    end

    def track_request action, options={}
      request = options.delete(:request)
      headers = request.headers.env.slice('HTTP_USER_AGENT','REMOTE_ADDR','HTTP_IF_MODIFIED_SINCE','HTTP_IF_NONE_MATCH')
      activity_tracker_for(action) << JSON.generate({action: action, params: options[:params], user_id: options[:user_id], stale: options[:stale], cache_key: options[:cache_key], headers: headers})
    end

    def report
      @actions.inject({}) do |memo,action_name|
        memo[action_name] = report_for(action_name)
        memo
      end
    end

    def report_for(action_name)
      base = {
        cache_keys:{},
        etags: {}
      }

      activity_for(action_name).inject(base) do |memo, tracked|
        cache_key = tracked.fetch("cache_key","")
        etag = tracked.fetch("headers").fetch("HTTP_IF_NONE_MATCH", "")

        memo[:etags][etag] ||= 0
        memo[:etags][etag] += 1
        memo[:cache_keys][cache_key] ||= 0
        memo[:cache_keys][cache_key] += 1

        memo
      end
    end

    module MonitoredActions
      extend ActiveSupport::Concern

      def index
        @activity_monitor = activity_monitor
        @activity_monitor.track_request(:index, user_id: current_user.try(:id), request: request, stale: stale_query?, cache_key: filter_context.cache_key, params: filter_context.params)
        super
      end

      def show
        @activity_monitor = activity_monitor
        @activity_monitor.track_request(:show, user_id: current_user.try(:id), request: request, stale: stale_object?, cache_key: filter_context.cache_key)
        super
      end
    end
  end
end
