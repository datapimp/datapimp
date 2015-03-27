module Datapimp
  class Sync::DropboxFolder < OpenStruct
    class_attribute :default_path_prefix, :default_root


    def push
      Datapimp.dropbox(token: client_token, secret: client_secret)
    end
  end
end
