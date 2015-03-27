module Datapimp
  class Sync::DropboxFolder < Hashie::Mash
    def dropbox
      @dropbox ||= Datapimp::Sync.dropbox
    end

    def delta
      @delta ||= dropbox.delta(cursor, remote_path)
    end

    def local_path
      Pathname(local)
    end

    def remote_path
      Datapimp::Sync.dropbox.ls(remote)
    end

    def cursor
      cursor_path.exist? && cursor_path.read
    end

    def cursor_path
      local_path.join('.dropbox-cursor')
    end

    def run(action)
      action = action.to_sym

      if action == :push

      elsif action == :pull

      end
    end
  end
end
