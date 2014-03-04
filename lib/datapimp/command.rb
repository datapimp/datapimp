require 'mutations'

class Datapimp::Command < Mutations::Command

  class << self
    attr_accessor :_prepare_with, :success_status, :error_status

    def documentation
      Hashie::Mash.new Datapimp::Command::Documentation.new(self).as_json
    end

    # yields params to the passed block
    # expects to get back params suitable for
    # being passed to the command class
    def prepare_with &block
      self._prepare_with = block if block_given?
      self._prepare_with
    end

    alias :run_without_prepare :run

    def run params
      run_without_prepare(prepare(params))
    end

    def prepare params={}
      prepare_with.respond_to?(:call) ? (prepare_with.call(params) && params) : params
    end
  end
end

require 'datapimp/command/policy'
require 'datapimp/command/documentation'

unless defined?(ApplicationCommand)
  ApplicationCommand = Class.new(Datapimp::Command)
end
