module Datapimp
  module Sync
    class S3Bucket < Hashie::Mash
      include Datapimp::Logging

      # returns the s3 bucket via fog
      def s3
        @s3 ||= Datapimp::Sync.amazon.storage.directories.get(remote)
      end

      def local_path
        Pathname(local)
      end

      def deploy_manifest_path
        Datapimp.config.deploy_manifests_path
          .tap {|p| FileUtils.mkdir_p(p) }
          .join(remote.to_s.parameterize + '.json')
      end

      def deploy_manifest
        @deploy_manifest ||= (JSON.parse(deploy_manifest_path.read) || {} rescue {})
      end

      def build_deploy_manifest_from_remote
        # TODO
        # Implement
      end

      # builds a manifest of MD5 hashes for each file
      # so that we aren't deploying stuff which is the
      # same since last time we deployed
      def prepare_manifest_for(entries)
        m = deploy_manifest

        entries.each do |entry|
          destination = Pathname(entry).relative_path_from(local_path).to_s.without_leading_slash

          deploy_manifest.fetch(destination) do
            next unless destination.match(/\w+\.\w+/)
            m[destination] = nil
          end
        end
      end

      def run_update_acl_action(options={})
        s3.files.each do |file|
          file.acl = 'public-read'
          file.save
          log "Updated acl for #{ file.key } to public-read"
        end
      end

      def run_push_action(options={})
        entries = Dir[local_path.join('**/*')].map(&:to_pathname)
        prepare_manifest_for(entries)

        entries.reject! { |entry| entry.to_s.match(/\.DS_Store/) }
        entries.reject!(&:directory?)

        count = 0
        entries.each do |entry|
          destination = entry.relative_path_from(local_path).to_s.without_leading_slash
          fingerprint = Digest::MD5.hexdigest(entry.read)

          if deploy_manifest[destination] == fingerprint
            #log "Skipping #{ destination }: found in manifest"
            next
          end

          if existing = s3.files.get(destination)
            if existing.etag == fingerprint
              log "Skipping #{ destination }: similar etag"
            else
              existing.body = entry.read
              existing.acl = 'public-read'
              log "Uploaded #{ destination }"
              existing.save
            end
          else
            log "Uploaded #{ destination }"
            s3.files.create(key: destination, body: entry.read, acl: 'public-read')
          end

          deploy_manifest[destination] = fingerprint
          count += 1
        end

        if count == 0
          return
        end

        log "Saving deploy manifest. #{ deploy_manifest.keys.length } entries"
        deploy_manifest_path.open("w+") {|fh| fh.write(deploy_manifest.to_json) }
      end

      def run_pull_action(options={})

      end

      def run(action, options={})
        action = action.to_sym

        if action == :push
          run_push_action(options)
        elsif action == :update_acl
          run_update_acl_action(options={})
        elsif action == :pull
          run_pull_action
        end
      end
    end
  end
end
