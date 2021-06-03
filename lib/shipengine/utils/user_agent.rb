# frozen_string_literal: true
module ShipEngine
  module Utils
    #
    # Class responsible for managing the user agent.
    #
    class UserAgent
      attr_reader :version, :platform
      def initialize(version = VERSION, platform = RUBY_PLATFORM)
        raise ::StandardError, "Cannot get version" unless version
        raise ::StandardError, "Cannot get platform" unless platform
        @version = version
        @platform = platform
      end

      def to_s
        "shipengine-ruby/#{@version} (#{@platform})"
      end
    end
  end
end
