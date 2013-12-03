require "rubygems"
require "datapimp/clients/amazon/sts"
require "aws"

module Datapimp::Clients::Amazon
  mattr_accessor :access_key_id, :secret_access_key

  def self.access_key_id
    @@access_key_id || ENV['ACCESS_KEY_ID']
  end

  def self.secret_access_key
    @@secret_access_key || ENV['SECRET_ACCESS_KEY']
  end

  def self.configure
    AWS.config({
      :access_key_id => access_key_id,
      :secret_access_key => secret_access_key
    })
  end

  def self.temporary_s3 options={}
    sts = Datapimp::Clients::Amazon::STS.new
    AWS::S3.new sts.credentials
  end
end

if defined?(::Rails)
  if File.exists?(Rails.root.join("config","aws.yml"))
    # IMPLEMENT
  end
end
