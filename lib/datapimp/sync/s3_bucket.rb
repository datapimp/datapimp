module Datapimp
  module Sync
    class S3Bucket < Hashie::Mash
      include Datapimp::Logging

      # returns the s3 bucket via fog
      def s3
        @s3 ||= storage.directories.get(remote).tap do |bucket|
          if setup_website == true
            bucket.public = true
            bucket.save
            storage.put_bucket_website(remote, 'index.html', key: 'error.html')
          end

          if redirect == true
            log "Should be creating a redirect bucket"
          end
        end
      end

      def cloudfront
        @cloudfront ||= Datapimp::Sync::CloudfrontDistribution.new(bucket: remote)
      end

      def storage
        Datapimp::Sync.amazon.storage
      end

      def website_hostname
        "#{s3.key}.s3-website-#{ s3.location }.amazonaws.com"
      end

      def website_url(proto="http")
        "#{proto}://#{ website_hostname }"
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
         deploy_manifest
      end

      def run_update_acl_action(options={})
        s3.files.each do |file|
          file.acl = 'public-read'
          file.save
          log "Updated acl for #{ file.key } to public-read"
        end
      end

      def asset_fingerprints
        deploy_manifest['asset_fingerprints'] ||= {}
      end

      def run_push_action(options={})
        require 'rack' unless defined?(::Rack)
        entries = Dir[local_path.join('**/*')].map(&:to_pathname)
        prepare_manifest_for(entries)

        entries.reject! { |entry| entry.to_s.match(/\.DS_Store/) }
        entries.reject!(&:directory?)

        uploaded = deploy_manifest['uploaded'] = []

        entries.each do |entry|
          destination = entry.relative_path_from(local_path).to_s.without_leading_slash
          fingerprint = Digest::MD5.hexdigest(entry.read)

          if asset_fingerprints[destination] == fingerprint
            #log "Skipping #{ destination }: found in manifest"
            next
          end

          content_type = Rack::Mime.mime_type(File.extname(destination.split("/").last))

          if existing = s3.files.get(destination)
            if existing.etag == fingerprint
              log "Skipping #{ destination }: similar etag"
            else
              existing.body = entry.read
              existing.acl = 'public-read'
              existing.content_type = content_type
              log "Updated #{ destination }; content-type: #{ content_type }"
              uploaded << destination
              existing.save
            end
          else
            log "Uploaded #{ destination }; content-type: #{ content_type }"
            s3.files.create(key: destination, body: entry.read, acl: 'public-read', content_type: content_type)
            uploaded << destination
          end

          asset_fingerprints[destination] = fingerprint
        end

        if count == 0
          return
        end

        log "Saving deploy manifest. #{ deploy_manifest.keys.length } entries"
        deploy_manifest_path.open("w+") {|fh| fh.write(deploy_manifest.to_json) }
      end

      def run_pull_action(options={})
        directories = Datapimp::Sync.amazon.storage.directories
        bucket = directories.get(remote)

        bucket.files.each do |file|
          local_file = local_path.join(file.key)
          next if local_file.exist? && file.etag == Digest::MD5.hexdigest(local_file.read)

          local_file.open("w+") {|fh| log("Updating docs entry") ;fh.write(file.body) }
        end
      end

      def run_create_action(options={})
        directories = Datapimp::Sync.amazon.storage.directories

        bucket = if existing = directories.get(remote)
          existing
        else
          directories.create(key:remote, public: true)
        end

        storage.put_bucket_website(remote, :IndexDocument => 'index.html', :ErrorDocument => 'error.html')

        bucket
      end

      def run(action, options={})
        action = action.to_sym

        if action == :push
          run_push_action(options)
        elsif action == :create
          run_create_action(options)
        elsif action == :update_acl
          run_update_acl_action(options={})
        elsif action == :pull
          run_pull_action
        end
      end
    end
  end
end
