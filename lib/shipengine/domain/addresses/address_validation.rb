# frozen_string_literal: true
module ShipEngine
  module Domain
    class Addresses
      module AddressValidation
        class Response
          attr_reader :status, :original_address, :matched_address, :messages

          # type ["unverified" | "verified" | "warning" | "error"] status
          # @param [NormalizedAddress] original_address
          # @param [NormalizedAddress?] matched_address
          # @param [Array<Response>] messages
          def initialize(status:, original_address:, matched_address:, messages:)
            @status = status
            @original_address = original_address
            @matched_address = matched_address
            @messages = messages
          end
        end

        class Request
          attr_reader :address_line1, :address_line2, :address_line3, :name, :company_name, :phone, :city_locality, :state_province, :postal_code,
            :country_code, :address_residential_indicator

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
          def initialize(address_line1:, address_line2:, address_line3:, name:, company_name:, phone:, city_locality:, state_province:, postal_code:,
            country_code:, address_residential_indicator:)

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

        class Address
          attr_reader :address_line1, :address_line2, :address_line3, :name, :company_name, :phone, :city_locality, :state_province, :postal_code,
            :country_code, :address_residential_indicator

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
          def initialize(address_line1:, address_line2:, address_line3:, name:, company_name:, phone:, city_locality:, state_province:, postal_code:,
            country_code:, address_residential_indicator:)

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

        class Message
          attr_reader :type, :code, :message

          # @param type [:info" | :warning | :error"]
          # @param code [String] = e.g. "suite_missing"
          def initialize(type:, code:, message:)
            @type = type
            @code = code
            @message = message
          end
        end
      end
    end
  end
end
