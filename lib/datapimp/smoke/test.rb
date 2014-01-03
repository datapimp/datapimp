module Datapimp::Smoke
  class Test
    attr_accessor :options,
                  :parent,
                  :deps,
                  :description

    def initialize(parent,options={})
      @parent = parent
      @options = options
      @description = options.fetch(:description)
    end

    def block
      options[:blk] || lambda { true }
    end

    def pass?
      !!result
    end

    def fail?
      !(pass?)
    end

    def run
      puts "  #{(fail? ? description.red : description.green)}"
    end

    def result
      @result ||= begin
                    instance_eval(&(block))
                  rescue
                    parent.register_error(description, $!)
                    false
                  end
    end

    def method_missing meth, *args, &blk
      if parent && parent.deps.has_key?(meth)
        source          = parent.deps[meth]
        return source[:output] if source.has_key?(:output)
        source[:output] = source[:block].call()
      end
    end
  end
end
