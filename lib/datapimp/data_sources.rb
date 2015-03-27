# The `Datapimp::Dataources` module houses the various
# types of remote data stores we are reading and converting into
# a JSON array of objects that gets cached on our filesystem.
module Datapimp
  module DataSources

  end
end

Dir[Datapimp.lib.join("datapimp/data_sources/**/*.rb")].each {|f| require(f) }
