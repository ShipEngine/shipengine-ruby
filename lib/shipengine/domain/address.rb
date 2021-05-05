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
      def validate(street:, country_code:, city_locality: nil, state_province: nil, postal_code: nil)
        @internal_client.validate_address({
                                            street: street,
                                            cityLocality: city_locality,
                                            stateProvince: state_province,
                                            postalCode: postal_code,
                                            countryCode: country_code
                                          })
      end
    end
  end
end
