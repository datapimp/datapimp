module Datapimp::Sync
  class Base
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def jsonify(value)
      case value
      when String, Numeric, NilClass, TrueClass, FalseClass
        value
      when Hash
        Hash[value.map { |k, v| [jsonify(k), jsonify(v)] }]
      when Array
        value.map { |v| jsonify(v) }
      when HappyMapper
        value.instance_variables.each_with_object({}) do |var_name, memo|
          key       = var_name.to_s.sub(/^@/, '').to_sym
          value     = obj.instance_variable_get(var_name)
          memo[key] = jsonify(value)
        end
      else
        attrs = if value.respond_to?(:to_attrs)
                  value.to_attrs
                elsif value.respond_to?(:as_json)
                  value.as_json
                else
                  value
                end
        jsonify attrs
      end
    end

    def serve_output(output)
      output = jsonify(output)

      if @options.format && @options.format == "json"
        output = JSON.generate(output)
      end

      if @options.output
        Pathname(options.output).open("w+") do |f|
          f.write(output)
        end
      elsif print_output?
        puts output.to_s
      else
        output
      end
    end

    private

    # Print output unless testing
    def print_output?
      ENV['TESTING'].nil?
    end
  end
end
