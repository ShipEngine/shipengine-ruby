# frozen_string_literal: true

module ShipEngine
  module Domain
    class Address
      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      def validate(address)
        @internal_client.validate_address(address)
      end
    end
  end
end
