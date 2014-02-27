module Datapimp
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/docs.rake"
    end

    generators do |app|
      app ||= Rails.application

      ::Rails::Generators.configure!(app.config.generators)
      ::Rails::Generators.hidden_namespaces.uniq!
      require_relative "../generators/resource_override"
    end
  end
end

