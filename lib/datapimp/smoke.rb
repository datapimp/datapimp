# I know I could just use rspec but
# i'm experimenting a little with writing
# a DSL for testing external API
module Datapimp
  module Smoke
    extend ActiveSupport::Autoload

    autoload :Dsl
    autoload :Group
    autoload :Test

    mattr_accessor :groups,
                   :current_group

    def self.groups
      @@groups ||= {}
    end

    def self.current_group= val
      @@current_group = val
    end

    def self.add_group description, options, &blk
      groups[current_group] = Group.new({
        description: description,
        options: options,
        blk:(blk)
      })
    end

    def self.find_groups_in(directory)
      Dir.glob("#{ directory }/**/*_test.rb")
    end

    def self.run(options={})
      load_dsl

      find_groups_in(options[:path]).each do |f|
        require(self.current_group=(f))
      end

      run_all_groups
    end

    def self.run_all_groups
      results = groups.values.map do |group|
        group.results
      end.flatten

      if results.any?(&:fail?)
        puts "\nNot ok.".red
        errors = groups.values.map(&:errors).reject {|e| e.empty? }

        if errors.empty?
          puts "Tests failed due to not meeting expectations"
        else
          puts "#{ errors.length } tests failed due to exceptions"
          puts errors.inspect
        end
      else
        puts "\nOk.".green
      end
    end

    def self.load_dsl
      Object.send(:extend, Datapimp::Smoke::Dsl::ClassMethods)
      Object.send(:include, Datapimp::Smoke::Dsl::ClassMethods)
      Object.send(:include, Datapimp::Smoke::Dsl)
    end
  end
end
