module Datapimp
  module Logging
    def log(*args)
      logger.send(:info, *args)
    end

    def logger= value
      @logger = value
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
