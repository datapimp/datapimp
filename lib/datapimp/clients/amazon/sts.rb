require "rubygems"
require "aws-sdk"

module Datapimp
  module Clients
    module Amazon
      class STS
        DefaultDuration = 60 * 60

        attr_accessor :options

        def initialize options={}
          @options = options

          Datapimp::Clients::Amazon.configure

          @client = AWS::STS.new
        end

        def client
          @client
        end

        def session
          return @session if @session

          @policy ||= AWS::STS::Policy.new
          @policy.allow(actions:["s3:*"], resources: :any)

          temporary_user = options.fetch :user, "TemporaryUser"
          duration = options.fetch :duration, DefaultDuration

          @session ||= client.new_federated_session(temporary_user, policy: @policy, duration: duration)
        end

        def credentials
          session.credentials
        end
      end
    end
  end
end
