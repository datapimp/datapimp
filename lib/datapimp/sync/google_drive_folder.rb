module Datapimp
  class Sync::GoogleDriveFolder < Hashie::Mash
    def api
      @api ||= Datapimp::Sync.google.api
    end

    def local_path
      Pathname(local)
    end

    def remote_path
      api.collection_by_title(remote)
    end

    def drawings
      remote_path.files.select {|file| file.mime_type == "application/vnd.google-apps.drawing" }
    end

    def run(action, options={})
      action = action.to_sym

      if action == :push

      elsif action == :pull

      elsif action == :svgs
        drawings.each do |drawing|
          filename = drawing.title.parameterize + '.svg'
          local_file = local_path.join(filename)

          if local_file.exist? && !options[:overwrite]
            puts "== #{ filename } already exists. skipping. pass --overwrite to overwrite"
          else
            puts "== Downloading to svg: #{ filename }"
            drawing.export_as_file(local_path.join(filename), 'image/svg+xml')
          end
        end
      end
    end
  end
end
