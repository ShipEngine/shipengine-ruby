# frozen_string_literal: true
require "hashie"
require_relative "rates/get_with_shipment_details"

module ShipEngine
  module Domain
    class Rates
      require "shipengine/constants"

      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      # @param shipment_details [Hash]
      # @param config [Hash?]
      #
      # @return [ShipEngine::Domain::Rates::GetWithShipmentDetails::Response]
      #
      # @see https://shipengine.github.io/shipengine-openapi/#operation/validate_address
      def get_rates_with_shipment_details(shipment_details, config)
        response = @internal_client.post("/v1/rates", shipment_details, config)
        rates_api_result = response.body
        mash_result = Hashie::Mash.new(rates_api_result)

        items = mash_result.items.map do |item|
          GetWithShipmentDetails::Response::Item.new(
            name: item.name,
            sales_order_id: item.sales_order_id,
            sales_order_item_id: item.sales_order_item_id,
            quantity: item.quantity,
            sku: item.sku,
            external_order_id: item.external_order_id,
            external_order_item_id: item.external_order_item_id,
            asin: item.asin,
            order_source_code: item.order_source_code
          )
        end

        tax_identifiers = mash_result.tax_identifiers.map do |tax_identifier|
          GetWithShipmentDetails::Response::TaxIdentifier.new(
            taxable_entity_type: tax_identifier.taxable_entity_type,
            identifier_type: tax_identifier.identifier_type,
            issuing_authority: tax_identifier.issuing_authority,
            value: tax_identifier.value
          )
        end

        tags = mash_result.tags.map do |tag|
          GetWithShipmentDetails::Response::Tag.new(
            name: tag.name
          )
        end

        packages = mash_result.packages.map do |package|
          weight = GetWithShipmentDetails::Response::Weight.new(
            value: package.weight.value,
            unit: package.weight.unit,
          )

          dimensions = nil
          if package.dimensions
            dimensions = GetWithShipmentDetails::Response::Dimensions.new(
              unit: package.dimensions.unit,
              length: package.dimensions["length"],
              width: package.dimensions.width,
              height: package.dimensions.height,
            )
          end

          insured_value = nil
          if package.insured_value
            insured_value = GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: package.insured_value.currency,
              amount: package.insured_value.amount,
            )
          end

          label_messages = nil
          if package.label_messages
            label_messages = GetWithShipmentDetails::Response::Package::LabelMessages.new(
              reference1: package.label_messages.reference1,
              reference2: package.label_messages.reference2,
              reference3: package.label_messages.reference3
            )
          end

          GetWithShipmentDetails::Response::Package.new(
            package_code: package.package_code,
            weight: weight,
            dimensions: dimensions,
            insured_value: insured_value,
            tracking_number: package.tracking_number,
            label_messages: label_messages,
            external_package_id: package.external_package_id
          )
        end

        customs = nil
        if mash_result.customs&.customs_items

          customs_items = mash_result.customs.customs_items.map do |customs_item|
            value = nil
            if customs_item.value
              value = GetWithShipmentDetails::Response::MonetaryValue.new(
                currency: customs_item.value.currency,
                amount: customs_item.value.amount,
              )
            end

            GetWithShipmentDetails::Response::Customs::CustomsItem.new(
              customs_item_id: customs_item.customs_item_id,
              description: customs_item.description,
              quantity: customs_item.quantity,
              value: value,
              harmonized_tariff_code: customs_item.harmonized_tariff_code,
              country_of_origin: customs_item.country_of_origin,
              unit_of_measure: customs_item.unit_of_measure,
              sku: customs_item.sku,
              sku_description: customs_item.sku_description
            )
          end

          customs = GetWithShipmentDetails::Response::Customs.new(
            contents: mash_result.customs.contents,
            non_delivery: mash_result.customs.non_delivery,
            customs_items: customs_items
          )
        end

        ship_to = GetWithShipmentDetails::Response::Address.new(
          address_line1: mash_result.ship_to.address_line1,
          address_line2: mash_result.ship_to.address_line2,
          address_line3: mash_result.ship_to.address_line3,
          name: mash_result.ship_to.name,
          company_name: mash_result.ship_to.company_name,
          phone: mash_result.ship_to.phone,
          city_locality: mash_result.ship_to.city_locality,
          state_province: mash_result.ship_to.state_province,
          postal_code: mash_result.ship_to.postal_code,
          country_code: mash_result.ship_to.country_code,
          address_residential_indicator: mash_result.ship_to.address_residential_indicator
        )

        ship_from = GetWithShipmentDetails::Response::Address.new(
          address_line1: mash_result.ship_from.address_line1,
          address_line2: mash_result.ship_from.address_line2,
          address_line3: mash_result.ship_from.address_line3,
          name: mash_result.ship_from.name,
          company_name: mash_result.ship_from.company_name,
          phone: mash_result.ship_from.phone,
          city_locality: mash_result.ship_from.city_locality,
          state_province: mash_result.ship_from.state_province,
          postal_code: mash_result.ship_from.postal_code,
          country_code: mash_result.ship_from.country_code,
          address_residential_indicator: mash_result.ship_from.address_residential_indicator
        )

        return_to = GetWithShipmentDetails::Response::Address.new(
          address_line1: mash_result.return_to.address_line1,
          address_line2: mash_result.return_to.address_line2,
          address_line3: mash_result.return_to.address_line3,
          name: mash_result.return_to.name,
          company_name: mash_result.return_to.company_name,
          phone: mash_result.return_to.phone,
          city_locality: mash_result.return_to.city_locality,
          state_province: mash_result.return_to.state_province,
          postal_code: mash_result.return_to.postal_code,
          country_code: mash_result.return_to.country_code,
          address_residential_indicator: mash_result.return_to.address_residential_indicator
        )

        dry_ice_weight = nil
        if mash_result.advanced_options.dry_ice_weight
          dry_ice_weight = GetWithShipmentDetails::Response::Weight.new(
            value: mash_result.advanced_options.dry_ice_weight.value,
            unit: mash_result.advanced_options.dry_ice_weight.unit,
          )
        end

        collect_on_delivery = nil
        if mash_result.advanced_options.collect_on_delivery

          payment_amount = nil
          if mash_result.advanced_options.collect_on_delivery.payment_amount
            payment_amount = GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: mash_result.advanced_options.collect_on_delivery.payment_amount.currency,
              amount: mash_result.advanced_options.collect_on_delivery.payment_amount.amount,
            )
          end

          collect_on_delivery = GetWithShipmentDetails::Response::AdvancedOptions::CollectOnDelivery.new(
            payment_type: mash_result.advanced_options.collect_on_delivery.payment_type,
            payment_amount: payment_amount
          )
        end

        advanced_options = GetWithShipmentDetails::Response::AdvancedOptions.new(
          bill_to_account: mash_result.advanced_options.bill_to_account,
          bill_to_country_code: mash_result.advanced_options.bill_to_country_code,
          bill_to_party: mash_result.advanced_options.bill_to_party,
          bill_to_postal_code: mash_result.advanced_options.bill_to_postal_code,
          contains_alcohol: mash_result.advanced_options.contains_alcohol,
          delivered_duty_paid: mash_result.advanced_options.delivered_duty_paid,
          dry_ice: mash_result.advanced_options.dry_ice,
          dry_ice_weight: dry_ice_weight,
          non_machinable: mash_result.advanced_options.non_machinable,
          saturday_delivery: mash_result.advanced_options.saturday_delivery,
          use_ups_ground_freight_pricing: mash_result.advanced_options.use_ups_ground_freight_pricing,
          freight_class: mash_result.advanced_options.freight_class,
          custom_field1: mash_result.advanced_options.custom_field1,
          custom_field2: mash_result.advanced_options.custom_field2,
          custom_field3: mash_result.advanced_options.custom_field3,
          origin_type: mash_result.advanced_options.origin_type,
          shipper_release: mash_result.advanced_options.shipper_release,
          collect_on_delivery: collect_on_delivery
        )

        total_weight = nil
        if mash_result.total_weight
          total_weight = GetWithShipmentDetails::Response::Weight.new(
            value: mash_result.total_weight.value,
            unit: mash_result.total_weight.unit,
          )
        end

        rates = mash_result.rate_response.rates.map do |rate|
          tax_amount = nil
          if rate.tax_amount
            tax_amount = GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: rate.tax_amount.currency,
              amount: rate.tax_amount.amount,
            )
          end

          GetWithShipmentDetails::Response::RateResponse::Rate.new(
            rate_id: rate.rate_id,
            rate_type: rate.rate_type,
            carrier_id: rate.carrier_id,
            shipping_amount: GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: rate.shipping_amount.currency,
              amount: rate.shipping_amount.amount,
            ),
            insurance_amount: GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: rate.insurance_amount.currency,
              amount: rate.insurance_amount.amount,
            ),
            confirmation_amount: GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: rate.confirmation_amount.currency,
              amount: rate.confirmation_amount.amount,
            ),
            other_amount: GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: rate.other_amount.currency,
              amount: rate.other_amount.amount,
            ),
            tax_amount: tax_amount,
            zone: rate.zone,
            package_type: rate.package_type,
            delivery_days: rate.delivery_days,
            guaranteed_service: rate.guaranteed_service,
            estimated_delivery_date: rate.estimated_delivery_date,
            carrier_delivery_days: rate.carrier_delivery_days,
            ship_date: rate.ship_date,
            negotiated_rate: rate.negotiated_rate,
            service_type: rate.service_type,
            service_code: rate.service_code,
            trackable: rate.trackable,
            carrier_code: rate.carrier_code,
            carrier_nickname: rate.carrier_nickname,
            carrier_friendly_name: rate.carrier_friendly_name,
            validation_status: rate.validation_status,
            warning_messages: rate.warning_messages,
            error_messages: rate.error_messages
          )
        end

        invalid_rates = mash_result.rate_response.invalid_rates.map do |rate|
          tax_amount = nil
          if rate.tax_amount
            tax_amount = GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: rate.tax_amount.currency,
              amount: rate.tax_amount.amount,
            )
          end

          GetWithShipmentDetails::Response::RateResponse::Rate.new(
            rate_id: rate.rate_id,
            rate_type: rate.rate_type,
            carrier_id: rate.carrier_id,
            shipping_amount: GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: rate.shipping_amount.currency,
              amount: rate.shipping_amount.amount,
            ),
            insurance_amount: GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: rate.insurance_amount.currency,
              amount: rate.insurance_amount.amount,
            ),
            confirmation_amount: GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: rate.confirmation_amount.currency,
              amount: rate.confirmation_amount.amount,
            ),
            other_amount: GetWithShipmentDetails::Response::MonetaryValue.new(
              currency: rate.other_amount.currency,
              amount: rate.other_amount.amount,
            ),
            tax_amount: tax_amount,
            zone: rate.zone,
            package_type: rate.package_type,
            delivery_days: rate.delivery_days,
            guaranteed_service: rate.guaranteed_service,
            estimated_delivery_date: rate.estimated_delivery_date,
            carrier_delivery_days: rate.carrier_delivery_days,
            ship_date: rate.ship_date,
            negotiated_rate: rate.negotiated_rate,
            service_type: rate.service_type,
            service_code: rate.service_code,
            trackable: rate.trackable,
            carrier_code: rate.carrier_code,
            carrier_nickname: rate.carrier_nickname,
            carrier_friendly_name: rate.carrier_friendly_name,
            validation_status: rate.validation_status,
            warning_messages: rate.warning_messages,
            error_messages: rate.error_messages
          )
        end

        errors = mash_result.rate_response.errors.map do |error|
          GetWithShipmentDetails::Response::RateResponse::Error.new(
            error_source: error.error_source,
            error_type: error.error_type,
            error_code: error.error_code,
            message: error["message"]
          )
        end

        rate_response = GetWithShipmentDetails::Response::RateResponse.new(
          rates: rates,
          invalid_rates: invalid_rates,
          rate_request_id: mash_result.rate_response.rate_request_id,
          shipment_id: mash_result.rate_response.shipment_id,
          created_at: mash_result.rate_response.created_at,
          status: mash_result.rate_response.status,
          errors: errors
        )

        GetWithShipmentDetails::Response.new(
          shipment_id: mash_result.shipment_id,
          carrier_id: mash_result.carrier_id,
          service_code: mash_result.service_code,
          external_order_id: mash_result.external_order_id,
          items: items,
          tax_identifiers: tax_identifiers,
          external_shipment_id: mash_result.external_shipment_id,
          ship_date: mash_result.ship_date,
          created_at: mash_result.created_at,
          modified_at: mash_result.modified_at,
          shipment_status: mash_result.shipment_status,
          ship_to: ship_to,
          ship_from: ship_from,
          warehouse_id: mash_result.warehouse_id,
          return_to: return_to,
          confirmation: mash_result.confirmation,
          customs: customs,
          advanced_options: advanced_options,
          origin_type: mash_result.origin_type,
          insurance_provider: mash_result.insurance_provider,
          tags: tags,
          order_source_code: mash_result.order_source_code,
          packages: packages,
          total_weight: total_weight,
          rate_response: rate_response,
        )
      end
    end
  end
end
