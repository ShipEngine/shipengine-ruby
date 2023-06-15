# frozen_string_literal: true

module ShipEngine
  module Domain
    class Carriers
      module ListCarriers
        class Response
          attr_reader :carriers, :request_id, :errors

          # @param [Carrier] carriers
          # @param [String?] request_id
          # @param [Array<Error>?] carriers
          def initialize(carriers:, request_id:, errors:)
            @carriers = carriers
            @request_id = request_id
            @errors = errors
          end
        end

        class Error
          attr_reader :error_source, :error_type, :error_code, :message

          # type ["carrier" | "order_source" | "shipengine"] error_source
          # type ["account_status" | "business_rules" | "validation" | "security" | "system" | "integrations"] error_type
          # @param [String] error_code
          # @param [String] message
          def initialize(error_source:, error_type:, error_code:, message:)
            @error_source = error_source
            @error_type = error_type
            @error_code = error_code
            @message = message
          end
        end

        class Carrier
          attr_reader :carrier_id, :carrier_code, :account_number, :requires_funded_amount, :balance, :nickname, :friendly_name, :primary, :has_multi_package_supporting_services, :supports_label_messages, :services, :packages, :options

          # @param [String] carrier_id - e.g. "se-28529731"
          # @param [String] carrier_code - e.g. "se-28529731"
          # @param [String] account_number - e.g. "account_570827"
          # @param [Boolean] requires_funded_amount - e.g. true
          # @param [Float] balance - e.g. 3799.52
          # @param [String] nickname - e.g. "ShipEngine Account - Stamps.com"
          # @param [String] friendly_name - e.g. "Stamps.com",
          # @param [Boolean] primary - e.g. true,
          # @param [Boolean] has_multi_package_supporting_services - e.g. true,
          # @param [Boolean] supports_label_messages - e.g. true,
          # @param [Array<Carrier::Service>] services
          # @param [Array<Carrier::Package>] packages
          # @param [Array<Carrier::Option>] options
          def initialize(carrier_id:, carrier_code:, account_number:, requires_funded_amount:, balance:, nickname:, friendly_name:, primary:, has_multi_package_supporting_services:, supports_label_messages:, services:, packages:, options:) # rubocop:todo Metrics/ParameterLists
            @carrier_id = carrier_id
            @carrier_code = carrier_code
            @account_number = account_number
            @requires_funded_amount = requires_funded_amount
            @balance = balance
            @nickname = nickname
            @friendly_name = friendly_name
            @primary = primary
            @has_multi_package_supporting_services = has_multi_package_supporting_services
            @supports_label_messages = supports_label_messages
            @services = services
            @packages = packages
            @options = options
          end

          class Service
            attr_reader :carrier_id, :carrier_code, :service_code, :name, :domestic, :international, :is_multi_package_supported

            # @param [String] carrier_id - e.g. "se-28529731"
            # @param [String] carrier_code - e.g. "se-28529731"
            # @param [String] service_code - e.g. "usps_media_mail"
            # @param [String] name - e.g. "USPS First Class Mail"
            # @param [Boolean] domestic - e.g. true
            # @param [Boolean] international - e.g. true
            # @param [Boolean] is_multi_package_supported - e.g. true

            def initialize(carrier_id:, carrier_code:, service_code:, name:, domestic:, international:, is_multi_package_supported:) # rubocop:todo Metrics/ParameterLists
              @carrier_id = carrier_id
              @carrier_code = carrier_code
              @service_code = service_code
              @name = name
              @domestic = domestic
              @international = international
              @is_multi_package_supported = is_multi_package_supported
            end
          end

          class Package
            attr_reader :package_id, :package_code, :name, :dimensions, :description

            # @param [String?] package_id - e.g. "se-28529731"
            # @param [String] package_code - e.g. "small_flat_rate_box"
            # @param [name] name - e.g. "laptop_box"
            # @param [Package::Dimensions?] dimensions - e.g. true
            # @param [String?] description - e.g. true

            def initialize(package_id:, package_code:, name:, dimensions:, description:)
              @package_id = package_id
              @package_code = package_code
              @name = name
              @dimensions = dimensions
              @description = description
            end

            class Dimensions
              attr_reader :unit, :length, :width, :height

              # type ["inch" | "centimeter"] unit
              # @param [Double] length - e.g. 1.0
              # @param [Double] width - e.g. 1.0
              # @param [Double] height - e.g. 1.0

              def initialize(unit:, length:, width:, height:)
                @unit = unit
                @length = length
                @width = width
                @height = height
              end
            end
          end

          class Option
            attr_reader :name, :default_value, :description

            # @param [String] name - e.g. "contains_alcohol"
            # @param [String] default_value - e.g. "false"
            # @param [String?] description - e.g. "Option"

            def initialize(name:, default_value:, description:)
              @name = name
              @default_value = default_value
              @description = description
            end
          end
        end
      end
    end
  end
end
