# This is an alternative to the Mutatable Controller mixin.
module Datapimp
  class Command::Runner
    InvalidCommand = Class.new(Exception)

    def self.run(command)
      new(command)
    end

    attr_accessor :command, :user, :inputs, :outcome

    def run
      @outcome ||= klass.run(inputs)
    end

    def as(user)
      @user = user
      self
    end

    def with(hash={})
      @inputs = klass.prepare(hash).merge(user: user)
    end

    def outcome
      @outcome ||= run()
    end

    def success?
      outcome.success?
    end

    def error_messages
      outcome.errors.message
    end

    def status
      success? ? success_status : error_status
    end

    def success_status
      klass.success_status || :ok
    end

    def error_status
      klass.error_status || :bad_request
    end

    def klass
      const = command.to_s.camelize
      const = const.constantize rescue nil
    end

    protected

      def initialize(command)
        @command = command.to_s
        raise InvalidCommand unless klass.present?
      end

  end
end
