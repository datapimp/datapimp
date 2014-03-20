# This gets included whenever a command class indicates that it is to
# run asynchronously.  It will alias the execute method, and replace it with
# its own version
module Datapimp::Command::Async
  extend ActiveSupport::Concern

  def worker_class
    (self.class.worker_klass || self.class.name + '::Worker').to_s.constantize
  end

  module ClassMethods
    def worker_class
      (worker_klass || name + '::Worker').to_s.constantize
    end

    def dispatch_asynchronously arguments={}
      arguments.keys.each do |key|
        value = arguments[key]
        if value.class <= ActiveRecord::Base
          arguments[key] = {_serialized_model: value.class.name, _id: value.id}
        end
      end

      worker_class.perform_async(arguments)
    end

    def run *args
      args = args.clone
      async? ? dispatch_asynchronously(args.extract_options!) : new(*args).run
    end
  end

  included do
    class << self
      attr_accessor :worker_klass
    end

    unless async_config.class_prepared
      Datapimp::Command::Async.configure_working_class(self)
    end

    self.async_config.class_prepared = true
  end

  # Class Modification
  def self.configure_working_class command_klass
    return if command_klass.worker_klass = (command_class.const_get(:Worker) rescue nil)

    command_klass.const_set(:Worker, define_worker_class(command_klass))
  end

  def self.define_worker_class command_klass
    command_klass.instance_eval <<-EOF
      class #{ command_klass.name }::Worker < Datapimp::Command::Worker
        use_command_class(#{ command_klass.name })

      end
    EOF
  end

end
