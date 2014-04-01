# Datapimp::Command
#
# This class is a wrapper around the `mutations` gem core Command class,
# with some API optimizations and additional functionality built in, such as:
#
# - Inline documentation and meta data
# - Asynchronous Handling
# - Security policies
# - Parameter hash pre-processing
#
require 'mutations'

class Datapimp::Command < Mutations::Command
  class << self
    attr_accessor :_prepare_with,
      :success_status,
      :error_status,
      :summary,
      :description,
      :_policy,
      :async_config

    # Asynchronous commands
    #
    # A Command class can be configured to automatically run in the background. It will
    # still work as a normal command, just the execute method will be run asynchronously
    # using the background worker system available in the project
    def run_asynchronously options={}
      async_config[:enabled] = true
      async_config.merge!(options)
      include(Datapimp::Command::Async)
    end

    def async_config
      @async_config ||= Hashie::Mash.new
    end

    def async?
      !async_config.empty?
    end

    # Security Policies
    #
    # A Command class can be configured to only be runnable by certain classes of users.
    # It can be configured to only allow certain parameters for certain classes of users, etc.
    def restrict_to *args
      options = args.extract_options!
      (self._policy ||= {}).merge(options)
    end

    def restricted_to *args
      send :restrict_to, *args
    end

    # Metadata
    #
    # Documenting the command inline while we define it will help in the automatic generation
    # of documentation
    def summarize_with short_description, *args
      self.summary = short_description
    end

    alias :summarize :summarize_with

    def describe_with description, *args
      self.description = description
    end

    alias :describe :describe_with

    def docs
      Hashie::Mash.new Datapimp::Command::Documentation.for_children_of(self)
    end

    def to_documentation
      Hashie::Mash.new Datapimp::Command::Documentation.new(self).as_json
    end

    # Shortcuts, Aliases and Grouping
    #
    # Different ways of referring to the command, useful for the CLI
    def command_group
      command_alias.split('_').slice(1,100).join("_").pluralize
    end

    def command_action
      command_alias.split('_').first
    end

    def command_alias
      self.name.to_s.underscore
    end

    def command_name
      "#{command_group}:#{command_action}"
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
require 'datapimp/command/async'
require 'datapimp/command/worker'
require 'datapimp/command/runner'
