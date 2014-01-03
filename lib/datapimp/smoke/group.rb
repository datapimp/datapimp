module Datapimp
  module Smoke
    class Group
      attr_accessor :options, :tests, :deps

      def initialize(options={})
        @options = options
        @tests = []
        @deps = {}
        instance_eval(&(options[:blk]))
      end

      def let(identifier,&blk)
        @deps[identifier] = {
          block: blk
        }
      end

      def it description,options={},&blk
        self.tests << Test.new(self, {
          description: description,
          options: options,
          blk: blk
        })
      end

      def description
        options[:description]
      end

      def errors
        @errors ||= {}
      end

      def register_error description, message
        errors[description] = message
      end

      def run_all
        puts description
        @results ||= tests.map {|test| test.run; test}
      end

      def results
        @results ||= run_all
      end
    end
  end
end
