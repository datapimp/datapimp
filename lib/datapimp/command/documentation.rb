module Datapimp
  class Command::Documentation
    attr_accessor :klass,
                  :inputs

    def self.input_filter_data(filter, base={})
      Hashie::Mash.new base.merge type: filter.class.name.split('::').last.gsub('Filter','').downcase, options: filter.options.reject {|k,v| v.nil? }
    end

    def initialize(klass)
      @klass = klass
    end

    def interface
      Hashie::Mash.new(as_json)
    end

    def as_json
      {
        class: klass.name,
        fields: fields
      }
    end

    def field *args
      self.class.send(:input_filter_data, *args)
    end

    def fields
      return @fields if @fields

      list = parse_fields(:required) + parse_fields(:optional)

      @fields = list.inject({}) do |memo,field|
        key = field.delete('key')
        memo[key] = field
        memo
      end
    end

    def parse_fields(source)
      source = self.send(source)

      list = source.map do |input_filter|
        key, config = input_filter
        results = []
        data = field(config, key: key, required: source == :required)

        if data[:type] == "hash"
          results += config.optional_inputs.map do |i|
            k,v = i
            field(v,key:k,scoped:key,required:false)
          end

          results += config.required_inputs.map do |i|
            k,v = i
            field(v,key:k,scoped:key,required:true)
          end
        else
          results << data
        end

        results
      end

      list.flatten
    end

    def input_filters
      klass.input_filters
    end

    def required
      input_filters.required_inputs
    end

    def optional
      input_filters.optional_inputs
    end

  end
end
