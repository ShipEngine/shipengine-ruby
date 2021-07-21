# frozen_string_literal: true
module ShipEngine
  class AddressValidationMessage
    attr_reader :type, :code, :message

    # @param type [:info" | :warning | :error"]
    # @param code [String] = e.g. "suite_missing"
    def initialize(type:, code:, message)
      @type = type
      @code = code
      @message = message
    end
  end

  class AddressValidationResult
    attr_reader :status, :original_address, :matched_address, :messages

    # type ["unverified" | "verified" | "warning" | "error"] status
    # @param [NormalizedAddress] original_address
    # @param [NormalizedAddress?] matched_address
    # @param [Array<AddressValidationMessage>] messages
    def initialize(status:, original_address:, matched_address:, messages:, request_id:)
      @status = status
      @original_address = original_address
      @matched_address = matched_address
      @messages = messages
      @request_id = request_id
    end
  end

  class NormalizedAddress
    attr_reader :address_line1, :address_line2, :address_line3, :name, :company_name, :phone, :city_locality, :state_province, :postal_code, :country_code, :address_residential_indicator

    # @param [String] address_line1 - e.g. ["123 FAKE ST."]
    # @param [String?] address_line2 - e.g. ["123 FAKE ST."]
    # @param [String?] address_line3 - e.g. ["123 FAKE ST."]
    # @param [String] country_code - e.g. "US". @see https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
    # @param [String] postal_code - e.g "78751"
    # @param [String?] name - e.g. "John Smith"
    # @param [String?] company_name - e.g. "ShipEngine"
    # @param [String?] phone - e.g. 5551234567
    # @param [String?] city_locality - e.g. "AUSTIN"
    # @param [String?] state_province - e.g. "TX"
    # @param [String?] address_residential_indicator
    def initialize(address_line1:, address_line2:, address_line3:, name:, company_name:, phone:, city_locality:, state_province:, postal_code:, country_code:, address_residential_indicator:)
      @name = name
      @company_name = company_name
      @address_line1 = address_line1
      @address_line2 = address_line2
      @address_line3 = address_line3
      @phone = phone
      @city_locality = city_locality
      @state_province = state_province
      @postal_code = postal_code
      @country_code = country_code
      @address_residential_indicator = address_residential_indicator
    end
  end

  module Domain
    class Address
      require "shipengine/utils/validate"
      require "shipengine/constants"
      class Validate
        class << self
          def assert_state_province(state_province)
            Utils::Validate.non_whitespace_str("State/province", state_province)
          end

          def assert_city_locality(city_locality)
            Utils::Validate.non_whitespace_str("City/locality", city_locality)
          end

          def assert_postal_code(postal_code)
            Utils::Validate.non_whitespace_str("Postal code", postal_code)
          end

          def assert_either_postal_code_or_city_state(postal_code:, city:, state:)
            if postal_code
              Validate.assert_postal_code(postal_code)
            elsif city && state
              Validate.assert_city_locality(city)
              Validate.assert_state_province(state)
            else
              raise Exceptions::ValidationError.new(
                message: "Invalid address. Either the postal code or the city/locality and state/province must be specified.",
                code: Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED)
              )
            end
          end

          def assert_address_line1(address_line1)
            if address_line1.empty?
              raise Exceptions::ValidationError.new(message: "Invalid address. Address Line 1 is required.",
                code: Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED))
            end
          end

          def assert_country_code(country_code)
            Utils::Validate.not_nil_or_empty_str("Invalid address. The country_code", country_code)
            return if Constants::Country.valid?(country_code)

            if country_code.nil? || (country_code == "")
              raise Exceptions.create_required_error(
                "Invalid address. The country_code"
              )
            end

            raise Exceptions.create_invalid_field_value_error(
              "Invalid address. #{country_code} is not a valid country_code code."
            )
          end
        end
      end

      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      # @param [String] address_line1
      # @param [String?] address_line2
      # @param [String?] address_line3
      # @param [String?] city_locality
      # @param [String?] state_province
      # @param [String?] postal_code
      # @param [String] country_code
      # @param [String?] phone
      # @param [String?] name
      # @param [String?] company
      # @return [ShipEngine::AddressValidationResult]
      def validate(address, config)
        address_params = address.compact # drop nil

        Validate.assert_address_line1(address[:address_line1])
        Validate.assert_country_code(address[:country_code])
        Validate.assert_either_postal_code_or_city_state(
          postal_code: address[:postal_code],
          city: address[:city_locality],
          state: address[:state_province]
        )

        response = @internal_client.post("/v1/addresses/validate", [address_params], config)
        address_api_result = response.body
        id = response.headers["x-shipengine-requestid"]

        normalized_original_address_api_result = address_api_result[0]["original_address"]
        normalized_matched_address_api_result = address_api_result[0]["matched_address"] || nil
        status = address_api_result[0]["status"]

        messages_classes = address_api_result[0]["messages"].map do |msg|
          AddressValidationMessage.new(type: msg["type"], code: msg["code"], message: msg["message"])
        end

        AddressValidationResult.new(
          request_id: id,
          status: status,
          messages: messages_classes,
          original_address: normalized_original_address_api_result,
          matched_address: normalized_matched_address_api_result,
        )
      end

      # @param response [AddressValidationResult]
      def result_is_successful(response)
       response.matched_address && response.status != "error"
      end

      #
      # Normalize an address
      #
      # @param address [@see #validate]
      # @param config [Hash] <description>
      #
      # @return [ShipEngine::NormalizedAddress] - return a `NormalizedAddress`.
      # Unlike the `validate` method, will throw a `ShipEngineError` if normalized_address is nil.
      def normalize(address, config)
        result = validate(address, config)

        return result.matched_address if result_is_successful(result)

        err_message = result.messages.map(&:message).join("\n")
        raise Exceptions::BusinessRulesError.new(
          message: "Invalid Address. #{err_message}",
          code: Exceptions::ErrorCode.get(:INVALID_ADDRESS),
          request_id: result.request_id
        )
      end
    end
  end
end
