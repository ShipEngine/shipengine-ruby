# frozen_string_literal: true

module ShipEngine
  module Domain
    class Address
      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      # @param [String] street - e.g. '123 Main Street'
      # @param [String?] city_locality - e.g. 'Austin'
      # @param [String?] state_province - e.g. 'TX'
      # @param [String?] postal_code - e.g. '78751'
      # @param [String] country_code - e.g. 'US'
      # @return [ShipEngine::Domain::Address::ValidateAddressResult]
      def validate(address, cfg)
        address_params = {
          street: address.fetch(:street),
          cityLocality: address.fetch(:city_locality, nil),
          stateProvince: address.fetch(:state_province, nil),
          postalCode: address.fetch(:postal_code, nil),
          countryCode: address.fetch(:country_code)
        }.compact # drop nil

        @internal_client.make_request('address.validate.v1', { address: address_params }, cfg)
      end
    end
  end
end
