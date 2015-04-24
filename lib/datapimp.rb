require 'ostruct'
require 'set'
require 'pathname'
require 'hashie'
require 'datapimp/core_ext'
require 'active_support'

module Datapimp
  def self.config
    Datapimp::Configuration.instance
  end

  def self.pwd
    Pathname(ENV.fetch('DATAPIMP_PWD') { Dir.pwd })
  end

  def self.lib
    Pathname(File.dirname(__FILE__))
  end

  def self.method_missing(meth, *args, &block)
    case
    when %w(dropbox amazon github google).include?(meth.to_s)
      Datapimp::Sync.send(meth, *args, &block)
    else
      super
    end
  end
end

require 'datapimp/version'
require 'datapimp/configuration'
require 'datapimp/logging'
require 'datapimp/sources'
require 'datapimp/sync'
require 'datapimp/sync/dropbox_folder'
require 'datapimp/sync/google_drive_folder'
require 'datapimp/sync/s3_bucket'
