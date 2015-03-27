module Datapimp
  module Sync
    class DropboxDelta

      attr_accessor :client,
                    :data,
                    :cursor,
                    :entries,
                    :path_prefix

      def initialize(client, cursor, path_prefix=nil)
        @client = client
        @cursor = cursor
        @path_prefix = path_prefix
      end

      def processed!
        # TODO
        # Should update cursor
      end

      def entries
        return @entries if @entries
        fetch
        @entries
      end

      def _dropbox_delta at=nil
        at ||= cursor
        response = client.delta(at, path_prefix)
        self.cursor = response["cursor"]
        response
      end

      def data
        @data ||= fetch
      end

      def on_reset path_prefix, cursor
      end

      def fetch
        return @response if @response

        response = _dropbox_delta

        if response["reset"] == true
          on_reset(path_prefix, cursor)
        end

        self.entries = {}.to_mash

        response["entries"].each do |entry|
          path, meta = entry
          self.entries[path] = meta
        end

        if response["has_more"] == true
          # TODO Implement
        end

        @response = response
      end

    end
  end
end
