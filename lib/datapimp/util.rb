module Datapimp
  module Util
    def self.load_config_file(at_path)
      at_path = Pathname(at_path)
      extension = at_path.extname.to_s.downcase

      raise 'No config file exists at: ' + at_path.to_s unless at_path.exist?

      if extension == '.yml' || extension == '.yaml'
        YAML.load_file(at_path)
      elsif extension == '.json'
        JSON.parse(at_path.read)
      end
    end
  end
end
