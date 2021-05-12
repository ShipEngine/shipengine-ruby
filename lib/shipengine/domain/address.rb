# frozen_string_literal: true

module ShipEngine
  class AddressValidationMessage
    attr_reader :type, :code, :message

    # @param type [:info" | :warning | :error"]
    # @param code [String] = e.g. "suite_missing"
    def initialize(type:, code:, message:)
      @type = type
      @code = code
      @message = message
    end
  end

  class AddressValidationResult
    attr_reader :normalized_address, :errors, :warnings, :info

    # @param [Boolean] valid
    # @param [NormalizedAddress] normalized_address
    # @param [AddressValidationMessage] errors
    # @param [AddressValidationMessage] warnings
    # @param [AddressValidationMessage] info
    def initialize(valid:, normalized_address:, errors:, warnings:, info:)
      @valid = valid
      @errors = errors
      @info = info
      @normalized_address = normalized_address
      @warnings = warnings
    end

    def valid?
      @valid
    end
  end

  class NormalizedAddress
    attr_reader :street, :name, :company, :phone, :city_locality, :state_province, :postal_code,
                :country

    # @param [Array<String>] street - e.g. ["123 FAKE ST."]
    # @param [String] country - e.g. "US". @see https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
    # @param [String] postal_code - e.g "78751"
    # @param [String?] name - e.g. "John Smith"
    # @param [String?] company - e.g. "ShipEngine"
    # @param [String?] phone - e.g. 5551234567
    # @param [String?] city_locality - e.g. "AUSTIN"
    # @param [String?] state_province - e.g. "TX"
    # @param [Boolean?] residential
    def initialize(street:, name:, company:, phone:, city_locality:, state_province:, postal_code:, country:, residential:)
      @street = street
      @name = name
      @company = company
      @phone = phone
      @city_locality = city_locality
      @state_province = state_province
      @postal_code = postal_code
      @country = country
      @residential = residential
    end

    def residential?
      @residential
    end
  end

  module Domain
    class Address
      require 'shipengine/utils/validate'
      require 'shipengine/constants'
      class Validate
        class << self
          def address_street(street)
            Utils::Validate.array_of_str('street', street)
            return if street.length <= 3

            if street.empty?
              raise Exceptions
                .create_required_error('Invalid address. At least one address line is required.')
            end

            raise Exceptions
              .create_invalid_field_value_error('Invalid address. No more than 3 street lines are allowed.')
          end

          def country(country)
            return if Constants::Country.valid?(country)

            if country.nil? || (country == '')
              raise Exceptions.create_required_error(
                'Invalid Address. The country'
              )
            end

            raise Exceptions.create_invalid_field_value_error(
              "Invalid Address. #{country} is not a valid country code."
            )
          end
      end
      end

      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      # @param [String] street
      # @param [String?] city_locality
      # @param [String?] state_province
      # @param [String?] postal_code
      # @param [String] country
      # @param [String?] phone
      # @param [String?] name
      # @param [String?] company
      # @return [ShipEngine::AddressValidationResult]
      def validate(address, cfg)
        address_params = {
          street: address.fetch(:street),
          cityLocality: address.fetch(:city_locality, nil),
          stateProvince: address.fetch(:state_province, nil),
          postalCode: address.fetch(:postal_code, nil),
          countryCode: address.fetch(:country),
          phone: address.fetch(:phone, nil),
          name: address.fetch(:name, nil),
          company: address.fetch(:company, nil)
        }.compact # drop nil

        Validate.address_street(address_params[:street])
        Validate.country(address_params[:countryCode])

        address_api_result = @internal_client.make_request('address.validate.v1',
                                                           { address: address_params }, cfg)

        normalized_address_api_result = address_api_result['normalizedAddress']

        AddressValidationResult.new(
          valid: address_api_result['isValid'],
          errors: address_api_result['errors'],
          warnings: address_api_result['warnings'],
          info: address_api_result['info'],
          normalized_address: NormalizedAddress.new(
            street: normalized_address_api_result['street'],
            name: normalized_address_api_result['name'],
            company: normalized_address_api_result['company'],
            phone: normalized_address_api_result['phone'],
            country: normalized_address_api_result['countryCode'],
            postal_code: normalized_address_api_result['postalCode'],
            state_province: normalized_address_api_result['stateProvince'],
            city_locality: normalized_address_api_result['cityLocality'],
            residential: normalized_address_api_result['isResidential']
          )
        )
      end
    end
  end
end
