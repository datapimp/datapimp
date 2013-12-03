module Datapimp::Clients
  module Github
    class IssueLabels < Datapimp::Clients::Github::Request
      Defaults = {
        # stage labels
        "s:backlog"       => "c7def8",
        "s:greenlit"      => "bfe5bf",
        "s:review"        => "fef2c0",
        "s:in_progress"   => "3ded58",

        # priority labels
        "p:1"             => "e11d21",
        "p:2"             => "eb6420",

        # type labels
        "t:development"   => "bada55",
        "t:design"        => "55adba",
        "t:ux"            => "2234fe",
        "t:project"       => "ae3498",

        # acceptance labels
        "a:approved"      => "339933",
        "a:rejected"      => "993333"
      }

      def missing_defaults
        current = all.collect(&:name)
        @missing_defaults ||= Defaults.keys - current
      end

      def missing_defaults?
        missing_defaults.length > 0
      end

      def create_status_sort_labels
        Defaults.each do |name, color|
          create_or_update(name, color)
        end
      end

      def delete_github_defaults
        %w{bug duplicate enhancement invalid wontfix question}.each do |name|
          destroy(name)
        end
      end

      def create_or_update name, color
        existing = show(name)

        unless existing.nil? || (existing.present? && existing.respond_to?(:message))
          update(name, name: name, color: color)
          return show(name)
        end

        create(name: name, color: color)
      end

      def endpoint
        "repos/#{ org }/#{ repo }/labels"
      end
    end
  end
end
