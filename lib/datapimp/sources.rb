# The `Datapimp::Sources` module houses the various
# types of remote data stores we are reading and converting into
# a JSON array of objects that gets cached on our filesystem.
#
module Datapimp
  module Sources
    class Base
      attr_reader :options, :name
      attr_accessor :raw, :processed, :format, :scopes, :slug_column, :refreshed_at, :path

      class << self
        attr_accessor :required_options
      end

      def self.requires *args
        self.required_options = args
      end

      def initialize(name, options={})
        @name     ||= name
        @options  ||= options
        @format   ||= options.fetch(:format, :json)
        @path     ||= options.fetch(:path) { Pathname(Dir.pwd()) }

        @slug_column = options.fetch(:slug_column, :_id)

        ensure_valid_options!
      end

      def to_s
        data.to_json
      end

      # defines a scope for the records in this data source
      # a scope is a named filter, implemented in the form of a block
      # which is passed each record.  if the block returns true, it returns
      # the record:
      #
      # Example:
      #
      # data_source(:galleries) do
      #   scope :active, -> {|record| record.state == "active" }
      # end
      def scope(*args, block)
        name = args.first
        (self.scopes ||= {})[name.to_sym] = block
      end

      def has_scope?(scope_name)
        scope_name && (self.scopes ||= {}).key?(scope_name.to_sym)
      end

      # compute properties takes the raw data of each record
      # and sets additional properties on the records which may
      # not be persited in the data source
      def compute_properties
        self.processed && self.processed.map! do |row|
          if slug_column && row.respond_to?(slug_column)
            row.slug = row.send(slug_column).to_s.parameterize
          end

          row
        end

        processors.each do |processor|
          original = self.processed.dup
          modified = []

          original.each_with_index do |record, index|
            previous = original[index - 1]
            modified.push(processor.call(record, index, previous: previous, set: original))
          end

          self.processed = modified
        end
      end

      def processors &block
        @processors ||= []
        @processors << block if block_given?
        @processors
      end

      # makes sure that the required options for this data source
      # are passed for any instance of the data source
      def ensure_valid_options!
        missing_options = (Array(self.class.required_options) - options.keys.map(&:to_sym))

        missing_options.reject! do |key|
          respond_to?(key) && !send(key).nil?
        end

        if missing_options.length > 0
          raise 'Error: failure to supply the following options: ' + missing_options.map(&:to_s).join(",")
        end
      end

      def select(&block)
        data.select(&block)
      end

      def refresh
        fetch
        process
        self.refreshed_at = Time.now.to_i
        self
      end

      def refresh_if_stale?
        refresh! if stale?
      end

      # A data source is stale if it has been populated
      # and the age is greater than the max age we allow.
      def stale?
        !need_to_refresh? && (age > max_age)
      end

      def fresh_on_server?
        need_to_refresh?
      end

      def max_age
        max = ENV['MAX_DATA_SOURCE_AGE']
        (max && max.to_i) || 120
      end

      # how long since this data source has been refreshed?
      def age
        Time.now.to_i - refreshed_at.to_i
      end

      def data
        refresh if need_to_refresh?
        processed
      end

      def refresh!
        refresh
        save_to_disk
      end

      def need_to_refresh?
        !(@fetched && @_processed)
      end

      def fetch
        @fetched = true
        self.raw = []
      end

      def preprocess
        self.raw.dup
      end

      def process
        @_processed = true
        self.processed = preprocess
        # set_id
        compute_properties
        self.processed
      end

      def refreshed_at
        return @refreshed_at if @refreshed_at.to_i > 0

        if path_to_file.exist?
          @refreshed_at = File.mtime(path.join(file)).to_i
        end
      end

      def save_to_disk
        unless path_to_file.dirname.exist?
          FileUtils.mkdir(path_to_file.dirname)
        end

        path_to_file.open('w+') {|fh| fh.write(to_s) }
      end

      def persisted?
        path_to_file && path_to_file.exist?
      end

      def file
        @file ||= name.parameterize if name.respond_to?(:parameterize)
        @file.gsub!("-","_")
        @file = "#{@file}.json" unless @file.match(/\.json/i)
        @file
      end

      def path_to_file
        Pathname(path).join("#{ file }")
      end
    end
  end
end

Dir[Datapimp.lib.join("datapimp/sources/**/*.rb")].each {|f| require(f) }
