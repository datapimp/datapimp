require 'rubygems'
require 'thor'
require 'thor/group'
require 'typhoeus'
require 'pry'

module Datapimp
  module Cli

    class << self
      attr_accessor :app, :host, :path
    end

    def self.path
      @meta_path || "/api/meta/commands.json"
    end

    def self.host
      @host || 'localhost:3000'
    end

    def self.app
      @app || 'datapimp'
    end

    class Base < Thor
      class << self
        def start(*args)
          ARGV.unshift('help') if ARGV.delete('--help')

          if ARGV[0] != "help" && (ARGV.length < 1 || ARGV.first.include?('-'))
            ARGV.unshift('help')
          end

          super
        end
      end

      desc 'version', 'Show Version'
      def version
        "Version"
      end

      def help(meth = nil, subcommand = false)
        if meth && !self.respond_to?(meth)
          klass, task = Thor::Util.find_class_and_task_by_namespace("#{meth}:#{meth}")
          klass.start(['h',task].compact, :shell => self.shell)
        else
          Typhoeus::Request.get("#{ Datapimp::Cli.host }/#{ Datapimp::Cli.path }")
        end
      end
    end
  end
end
