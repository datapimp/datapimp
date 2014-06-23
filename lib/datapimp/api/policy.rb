module Datapimp
  class Api
    class Policy < Hashie::Mash
      def apply_options options={}
      end

      def authenticate_with options={}
      end

      def allow resource, options={}
      end

      def disallow resource, options={}
      end

      def same_as policy_name
      end

      def test test_method
      end
    end
  end
end
