# frozen_string_literal: true
require "hashie"
require_relative "addresses/address_validation"

module ShipEngine
  module Domain
    class Addresses
      require "shipengine/constants"

      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      # @param addresses [ShipEngine::Domain::Addresses::AddressValidationRequest]
      # @param config [Hash?]
      #
      # @return [Array<ShipEngine::Domain::Addresses::AddressValidationResponse>]
      #
      # @see https://shipengine.github.io/shipengine-openapi/#operation/validate_address
      def validate(addresses, config)
        addresses_array = addresses.map(&:compact)

        response = @internal_client.post("/v1/addresses/validate", addresses_array, config)
        address_api_result = response.body

        address_api_result.map do |result|
          mash_result = Hashie::Mash.new(result)
          normalized_original_address_api_result = AddressValidation::Address.new(
            address_line1: mash_result.original_address.address_line1,
            address_line2: mash_result.original_address.address_line2,
            address_line3: mash_result.original_address.address_line3,
            name: mash_result.original_address.name,
            company_name: mash_result.original_address.company_name,
            phone: mash_result.original_address.phone,
            city_locality: mash_result.original_address.city_locality,
            state_province: mash_result.original_address.state_province,
            postal_code: mash_result.original_address.postal_code,
            country_code: mash_result.original_address.country_code,
            address_residential_indicator: mash_result.original_address.address_residential_indicator
          )

          normalized_matched_address_api_result = if mash_result.matched_address
            AddressValidation::Address.new(
              address_line1: mash_result.matched_address.address_line1,
              address_line2: mash_result.matched_address.address_line2,
              address_line3: mash_result.matched_address.address_line3,
              name: mash_result.matched_address.name,
              company_name: mash_result.matched_address.company_name,
              phone: mash_result.matched_address.phone,
              city_locality: mash_result.matched_address.city_locality,
              state_province: mash_result.matched_address.state_province,
              postal_code: mash_result.matched_address.postal_code,
              country_code: mash_result.matched_address.country_code,
              address_residential_indicator: mash_result.matched_address.address_residential_indicator
            )
          end

          status = mash_result.status

          messages_classes = mash_result.messages.map do |msg|
            AddressValidation::Message.new(type: msg["type"], code: msg["code"], message: msg["message"])
          end

          AddressValidation::Response.new(
            status: status,
            messages: messages_classes,
            original_address: normalized_original_address_api_result,
            matched_address: normalized_matched_address_api_result,
          )
        end
      end
    end
  end
end
