module Datapimp::Smoke::Dsl
  extend ActiveSupport::Concern

  module ClassMethods
    def smoke(description, *args, &blk)
      options = args.extract_options!
      Datapimp::Smoke.add_group(description, options, &blk)
    end
  end
end
