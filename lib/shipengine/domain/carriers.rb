# frozen_string_literal: true

require "hashie"
require_relative "carriers/list_carriers"
require "shipengine/constants"
require "pry"

module ShipEngine
  module Domain
    class Carriers
      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      def list_carriers(config:)
        response = @internal_client.get("/v1/carriers", {}, config)
        carriers_api_result = response.body
        mash_result = Hashie::Mash.new(carriers_api_result)
        carriers = mash_result.carriers.map do |carrier|
          services = carrier.services.map do |service|
            ListCarriers::Carrier::Service.new(
              carrier_id: service.carrier_id,
              carrier_code: service.carrier_code,
              service_code: service.service_code,
              name: service.name,
              domestic: service.domestic,
              international: service.international,
              is_multi_package_supported: service.is_multi_package_supported,
            )
          end

          packages = carrier.packages.map do |package|
            dimensions = nil
            if package.dimensions
              dimensions = ListCarriers::Carrier::Package::Dimensions.new(
                unit: package.dimensions.unit,
                length: package.dimensions.length,
                width: package.dimensions.width,
                height: package.dimensions.height,
              )
            end
            ListCarriers::Carrier::Package.new(
              package_id: package.package_id,
              package_code: package.package_code,
              name: package.name,
              dimensions: dimensions,
              description: package.description
            )
          end

          options = carrier.options.map do |option|
            ListCarriers::Carrier::Option.new(
              name: option.name,
              default_value: option.default_value,
              description: option.description
            )
          end

          ListCarriers::Carrier.new(
            carrier_id: carrier.carrier_id,
            carrier_code: carrier.carrier_code,
            account_number: carrier.account_number,
            requires_funded_amount: carrier.requires_funded_amount,
            balance: carrier.balance,
            nickname: carrier.nickname,
            friendly_name: carrier.friendly_name,
            primary: carrier.primary,
            has_multi_package_supporting_services: carrier.has_multi_package_supporting_services,
            supports_label_messages: carrier.supports_label_messages,
            services: services,
            packages: packages,
            options: options
          )
        end

        errors = mash_result.errors.map do |error|
          ListCarriers::Error.new(
            error_source: error.error_source,
            error_type: error.error_type,
            error_code: error.error_code,
            message: error["message"]
          )
        end

        ListCarriers::Response.new(
          carriers: carriers,
          request_id: mash_result.request_id,
          errors: errors
        )
      end
    end
  end
end
