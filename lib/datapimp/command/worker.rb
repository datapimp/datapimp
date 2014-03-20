class Datapimp::Command::Worker
  if defined?(Sidekiq::Worker)
    include Sidekiq::Worker
  end

  def perform arguments
    arguments.keys.each do |key|
      value = arguments[key]

      if value.is_a?(Hash)
        value = value.with_indifferent_access
        klass = value[:_serialized_model].constantize
        arguments[key] = klass.find(value[:_id])
      end
    end

    command_class.new(arguments).run
  end

  def command_class
    return @@command_class if @@command_class

    parts = self.name.to_s.split('::'); parts.pop
    parts.join('::').constantize rescue nil
  end

  def self.use_command_class klass_name
    @@command_class = klass_name.is_a?(String) ? klass_name.constantize : klass_name
  end

  def self.worker_options *args, &block
    send(:sidekiq_options, *args, &block)
  end
end
