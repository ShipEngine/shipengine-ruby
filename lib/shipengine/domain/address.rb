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
    attr_reader :normalized_address, :errors, :warnings, :info, :request_id

    # @param [Boolean] valid
    # @param [NormalizedAddress] normalized_address
    # @param [Array<AddressValidationMessage>] errors
    # @param [Array<AddressValidationMessage>] warnings
    # @param [Array<AddressValidationMessage>] info
    def initialize(valid:, normalized_address:, errors:, warnings:, info:, request_id:)
      @valid = valid
      @errors = errors
      @info = info
      @normalized_address = normalized_address
      @warnings = warnings
      @request_id = request_id
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
    def initialize(street:, name:, company:, phone:, city_locality:, state_province:, postal_code:, country:, residential:) # rubocop:disable Metrics/ParameterLists
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
          def assert_state_province(state_province)
            Utils::Validate.non_whitespace_str('State/province', state_province)
          end

          def assert_city_locality(city_locality)
            Utils::Validate.non_whitespace_str('City/locality', city_locality)
          end

          def assert_postal_code(postal_code)
            Utils::Validate.non_whitespace_str('Postal code', postal_code)
          end

          def assert_either_postal_code_or_city_state(postal_code:, city:, state:)
            if postal_code
              Validate.assert_postal_code(postal_code)
            elsif city && state
              Validate.assert_city_locality(city)
              Validate.assert_state_province(state)
            else
              raise Exceptions::ValidationError.new(
                message: 'Invalid address. Either the postal code or the city/locality and state/province must be specified.',
                code: Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED)
              )
            end
          end

          def assert_address_street(street)
            Utils::Validate.array_of_str('Street', street)

            if street.empty?
              raise Exceptions::ValidationError.new(message: 'Invalid address. At least one address line is required.',
                                                    code: Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED))
            elsif street.length > 3
              raise Exceptions
                .create_invalid_field_value_error('Invalid address. No more than 3 street lines are allowed.')
            end
          end

          def assert_country(country)
            Utils::Validate.not_nil_or_empty_str('Invalid address. The country', country)
            return if Constants::Country.valid?(country)

            if country.nil? || (country == '')
              raise Exceptions.create_required_error(
                'Invalid address. The country'
              )
            end

            raise Exceptions.create_invalid_field_value_error(
              "Invalid address. #{country} is not a valid country code."
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
      def validate(address, config)
        address_params = {
          street: address[:street],
          cityLocality: address[:city_locality],
          stateProvince: address[:state_province],
          postalCode: address[:postal_code],
          countryCode: address[:country],
          phone: address[:phone],
          name: address[:name],
          company: address[:company]
        }.compact # drop nil

        Validate.assert_address_street(address_params[:street])
        Validate.assert_country(address_params[:countryCode])
        Validate.assert_either_postal_code_or_city_state(
          postal_code: address_params[:postalCode],
          city: address_params[:cityLocality], state: address_params[:stateProvince]
        )

        address_api_result = @internal_client.make_request('address.validate.v1',
                                                           { address: address_params }, config)

        normalized_address_api_result = address_api_result['normalizedAddress'] || nil

        messages_classes = address_api_result['messages'].map do |msg|
          AddressValidationMessage.new(type: msg['type'], code: msg['code'], message: msg['message'])
        end

        AddressValidationResult.new(
          request_id: address_api_result['requestId'],
          valid: address_api_result['isValid'],
          errors: messages_classes.select { |msg| msg.type == 'error' },
          warnings: messages_classes.select { |msg| msg.type == 'warning' },
          info: messages_classes.select { |msg| msg.type == 'info' },
          normalized_address: normalized_address_api_result && NormalizedAddress.new(
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

      # @param response [AddressValidationResult]
      def result_is_successful(response)
        response.valid? and response.normalized_address and response.errors.empty?
      end

      #
      # Normalize an address
      #
      # @param address [@see #validate]
      # @param config [Hash] <description>
      #
      # @return [ShipEngine::NormalizedAddress] - return a `NormalizedAddress`.
      # Unlike the `validate` method, will throw a `ShipEngineError` if normalized_address is nil.
      #
      def normalize(address, config)
        result = validate(address, config)

        return result.normalized_address if result_is_successful(result)

        err_message = result.errors.map { |err| err.message }.join("\n")
        raise Exceptions::BusinessRulesError.new(
          message: "Invalid Address. #{err_message}",
          code: Exceptions::ErrorCode.get(:INVALID_ADDRESS),
          request_id: result.request_id
          # Even though we are constructing this HERE, this should be something we could just grab from the server
        )
      end
    end
  end
end
