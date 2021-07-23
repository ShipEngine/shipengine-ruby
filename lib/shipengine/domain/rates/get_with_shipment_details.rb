# frozen_string_literal: true
module ShipEngine
  module Domain
    class Rates
      module GetWithShipmentDetails
        class Response
          attr_reader :shipment_id, :carrier_id, :service_code, :external_order_id, :items, :tax_identifiers, :external_shipment_id, :ship_date, :created_at, :modified_at, :shipment_status, :ship_to, :ship_from, :warehouse_id, :return_to, :confirmation, :customs, :advanced_options, :origin_type,
            :insurance_provider, :tags, :order_source_code, :packages, :total_weight, :rate_response

          def initialize(shipment_id:, carrier_id:, service_code:, external_order_id:, items:, tax_identifiers:, external_shipment_id:, ship_date:, created_at:, modified_at:, shipment_status:, ship_to:, ship_from:, warehouse_id:, return_to:, confirmation:, customs:, advanced_options:, origin_type:,
            insurance_provider:, tags:, order_source_code:, packages:, total_weight:, rate_response:)
            @shipment_id = shipment_id
            @carrier_id = carrier_id
            @service_code = service_code
            @external_order_id = external_order_id
            @items = items
            @tax_identifiers = tax_identifiers
            @external_shipment_id = external_shipment_id
            @ship_date = ship_date
            @created_at = created_at
            @modified_at = modified_at
            @shipment_status = shipment_status
            @ship_to = ship_to
            @ship_from = ship_from
            @warehouse_id = warehouse_id
            @return_to = return_to
            @confirmation = confirmation
            @customs = customs
            @advanced_options = advanced_options
            @origin_type = origin_type
            @insurance_provider = insurance_provider
            @tags = tags
            @order_source_code = order_source_code
            @packages = packages
            @total_weight = total_weight
            @rate_response = rate_response
          end

          class Item
            attr_reader :name, :sales_order_id, :sales_order_item_id, :quantity, :sku, :external_order_id, :external_order_item_id, :asin, :order_source_code

            def initialize(name:, sales_order_id:, sales_order_item_id:, quantity:, sku:, external_order_id:, external_order_item_id:, asin:, order_source_code:)
              @name = name
              @sales_order_id = sales_order_id
              @sales_order_item_id = sales_order_item_id
              @quantity = quantity
              @sku = sku
              @external_order_id = external_order_id
              @external_order_item_id = external_order_item_id
              @asin = asin
              @order_source_code = order_source_code
            end
          end

          class TaxIdentifier
            attr_reader :taxable_entity_type, :identifier_type, :issuing_authority, :value

            def initialize(taxable_entity_type:, identifier_type:, issuing_authority:, value:)
              @taxable_entity_type = taxable_entity_type
              @identifier_type = identifier_type
              @issuing_authority = issuing_authority
              @value = value
            end
          end

          class Address
            attr_reader :name, :phone, :company_name, :address_line1, :address_line2, :address_line3, :city_locality, :state_province, :postal_code, :country_code, :address_residential_indicator

            def initialize(name:, phone:, company_name:, address_line1:, address_line2:, address_line3:, city_locality:, state_province:, postal_code:, country_code:, address_residential_indicator:)
              @name = name
              @phone = phone
              @company_name = company_name
              @address_line1 = address_line1
              @address_line2 = address_line2
              @address_line3 = address_line3
              @city_locality = city_locality
              @state_province = state_province
              @postal_code = postal_code
              @country_code = country_code
              @address_residential_indicator = address_residential_indicator
            end
          end

          class Customs
            attr_reader :contents, :non_delivery, :customs_items

            def initialize(contents:, non_delivery:, customs_items:)
              @contents = contents
              @non_delivery = non_delivery
              @customs_items = customs_items
            end

            class CustomsItem
              attr_reader :customs_item_id, :description, :quantity, :value, :harmonized_tariff_code, :country_of_origin, :unit_of_measure, :sku, :sku_description

              def initialize(customs_item_id:, description:, quantity:, value:, harmonized_tariff_code:, country_of_origin:, unit_of_measure:, sku:, sku_description:)
                @customs_item_id = customs_item_id
                @description = description
                @quantity = quantity
                @value = value
                @harmonized_tariff_code = harmonized_tariff_code
                @country_of_origin = country_of_origin
                @unit_of_measure = unit_of_measure
                @sku = sku
                @sku_description = sku_description
              end
            end
          end

          class MonetaryValue
            attr_reader :currency, :amount

            def initialize(currency:, amount:)
              @currency = currency
              @amount = amount
            end
          end

          class Weight
            attr_reader :value, :unit

            def initialize(value:, unit:)
              @value = value
              @unit = unit
            end
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

          class AdvancedOptions
            attr_reader :bill_to_account, :bill_to_country_code, :bill_to_party, :bill_to_postal_code, :contains_alcohol, :delivered_duty_paid, :dry_ice, :dry_ice_weight, :non_machinable, :saturday_delivery, :use_ups_ground_freight_pricing, :freight_class, :custom_field1, :custom_field2,
              :custom_field3, :origin_type, :shipper_release, :collect_on_delivery

            def initialize(bill_to_account:, bill_to_country_code:, bill_to_party:, bill_to_postal_code:, contains_alcohol:, delivered_duty_paid:, dry_ice:, dry_ice_weight:, non_machinable:, saturday_delivery:, use_ups_ground_freight_pricing:, freight_class:, custom_field1:, custom_field2:,
              custom_field3:, origin_type:, shipper_release:, collect_on_delivery:)
              @bill_to_account = bill_to_account
              @bill_to_country_code = bill_to_country_code
              @bill_to_party = bill_to_party
              @bill_to_postal_code = bill_to_postal_code
              @contains_alcohol = contains_alcohol
              @delivered_duty_paid = delivered_duty_paid
              @dry_ice = dry_ice
              @dry_ice_weight = dry_ice_weight
              @non_machinable = non_machinable
              @saturday_delivery = saturday_delivery
              @use_ups_ground_freight_pricing = use_ups_ground_freight_pricing
              @freight_class = freight_class
              @custom_field1 = custom_field1
              @custom_field2 = custom_field2
              @custom_field3 = custom_field3
              @origin_type = origin_type
              @shipper_release = shipper_release
              @collect_on_delivery = collect_on_delivery
            end

            class CollectOnDelivery
              attr_reader :payment_type, :payment_amount

              def initialize(payment_type:, payment_amount:)
                @payment_type = payment_type
                @payment_amount = payment_amount
              end
            end
          end

          class Tag
            attr_reader :name

            def initialize(name:)
              @name = name
            end
          end

          class Package
            attr_reader :package_code, :weight, :dimensions, :insured_value, :tracking_number, :label_messages, :external_package_id

            def initialize(package_code:, weight:, dimensions:, insured_value:, tracking_number:, label_messages:, external_package_id:)
              @package_code = package_code
              @weight = weight
              @dimensions = dimensions
              @insured_value = insured_value
              @tracking_number = tracking_number
              @label_messages = label_messages
              @external_package_id = external_package_id
            end

            class LabelMessages
              attr_reader :reference1, :reference2, :reference3

              def initialize(reference1:, reference2:, reference3:)
                @reference1 = reference1
                @reference2 = reference2
                @reference3 = reference3
              end
            end
          end

          class RateResponse
            attr_reader :rates, :invalid_rates, :rate_request_id, :shipment_id, :created_at, :status, :errors

            def initialize(rates:, invalid_rates:, rate_request_id:, shipment_id:, created_at:, status:, errors:)
              @rates = rates
              @invalid_rates = invalid_rates
              @rate_request_id = rate_request_id
              @shipment_id = shipment_id
              @created_at = created_at
              @status = status
              @errors = errors
            end

            class Rate
              attr_reader :rate_id, :rate_type, :carrier_id, :shipping_amount, :insurance_amount, :confirmation_amount, :other_amount, :tax_amount, :zone, :package_type, :delivery_days, :guaranteed_service, :estimated_delivery_date, :carrier_delivery_days, :ship_date, :negotiated_rate,
                :service_type, :service_code, :trackable, :carrier_code, :carrier_nickname, :carrier_friendly_name, :validation_status, :warning_messages, :error_messages

              def initialize(rate_id:, rate_type:, carrier_id:, shipping_amount:, insurance_amount:, confirmation_amount:, other_amount:, tax_amount:, zone:, package_type:, delivery_days:, guaranteed_service:, estimated_delivery_date:, carrier_delivery_days:, ship_date:, negotiated_rate:,
                service_type:, service_code:, trackable:, carrier_code:, carrier_nickname:, carrier_friendly_name:, validation_status:, warning_messages:, error_messages:)
                @rate_id = rate_id
                @rate_type = rate_type
                @carrier_id = carrier_id
                @shipping_amount = shipping_amount
                @insurance_amount = insurance_amount
                @confirmation_amount = confirmation_amount
                @other_amount = other_amount
                @tax_amount = tax_amount
                @zone = zone
                @package_type = package_type
                @delivery_days = delivery_days
                @guaranteed_service = guaranteed_service
                @estimated_delivery_date = estimated_delivery_date
                @carrier_delivery_days = carrier_delivery_days
                @ship_date = ship_date
                @negotiated_rate = negotiated_rate
                @service_type = service_type
                @service_code = service_code
                @trackable = trackable
                @carrier_code = carrier_code
                @carrier_nickname = carrier_nickname
                @carrier_friendly_name = carrier_friendly_name
                @validation_status = validation_status
                @warning_messages = warning_messages
                @error_messages = error_messages
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
          end
        end
      end
    end
  end
end
