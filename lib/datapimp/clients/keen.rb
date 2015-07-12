module Datapimp
  module Clients
    class Keen
      include Singleton

      def self.method_missing(meth, *args, &block)
        if client.respond_to?(meth)
          return client.send(meth, *args, &block)
        end

        super
      end

      def self.client(options={})
        Keen
      end

      def options
        @options ||= {}
      end

      def with_options(opts={})
        options.merge!(opts)
        self
      end

      def setup(options={})
        access_token = options[:keen_read_key] || Datapimp.config.keen_read_key
        project_id = options[:keen_project_id] || Datapimp.config.keen_project_id

        unless access_token.to_s.length > 1
          if respond_to?(:ask)
            access_token = ask("Enter a keen read key when  you have one", String)
          end
        end

        unless project_id.to_s.length > 1
          if respond_to?(:ask)
            project_id = ask("Enter a keen read key when  you have one", String)
          end
        end

        Datapimp.config.set(:keen_read_key, access_token) if access_token.to_s.length > 1
        Datapimp.config.set(:keen_project_id, project_id) if project_id.to_s.length > 1
      end
    end
  end
end
