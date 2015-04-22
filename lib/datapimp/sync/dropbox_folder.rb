module Datapimp
  class Sync::DropboxFolder < Hashie::Mash
    # Provides easy access to the Dropbox client
    def dropbox
      @dropbox ||= Datapimp::Sync.dropbox
    end

    # Provides access to the Dropbox API Delta which will tell us
    # how to modify the state of `local_path` to match what exists
    # on Dropbox.
    def delta
      @delta ||= dropbox.delta(cursor, remote_path)
    end

    # A Pointer to the local path we will be syncing with the Dropbox remote
    def local_path
      Pathname(local)
    end

    # The Dropbox Delta API uses a cursor to keep track of the last state
    # the local filesystem has synced with.  We store this in the syncable folder
    # itself
    def cursor
      cursor_path.exist? && cursor_path.read
    end

    def cursor_path
      local_path.join('.dropbox-cursor')
    end

    def remote_path
      dropbox.ls(remote)
    rescue(Dropbox::API::Error::NotFound)
      nil
    end

    def remote_path_parent
      parent, _ = File.split(remote)
      dropbox.ls(parent)
    rescue(Dropbox::API::Error::NotFound)
      nil
    end

    def remote_path_missing?
      remote_path.nil?
    end

    def run(action, options={})
      action = action.to_sym

      if action == :push
        if remote_path_missing?
          dropbox.mkdir(remote)
        end

        Dir[local_path.join("**/*")].each do |f|
          # Upload the file
          binding.pry
        end

      elsif action == :pull
        # TODO
        # Implement the Delta call
      end
    end

    def ensure_remote_folder_exists
    end
  end
end

