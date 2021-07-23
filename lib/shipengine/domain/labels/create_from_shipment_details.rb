# frozen_string_literal: true
module ShipEngine
  module Domain
    class Labels
      module CreateFromShipmentDetails
        class Response
          attr_reader :label_id, :status, :shipment_id, :ship_date, :created_at, :shipment_cost, :insurance_cost, :tracking_number, :is_return_label, :rma_number, :is_international, :batch_id, :carrier_id, :charge_event, :service_code, :package_code, :voided, :voided_at, :label_format,
            :display_scheme, :label_layout, :trackable, :label_image_id, :carrier_code, :tracking_status, :label_download, :form_download, :insurance_claim, :packages

          def initialize(label_id:, status:, shipment_id:, ship_date:, created_at:, shipment_cost:, insurance_cost:, tracking_number:, is_return_label:, rma_number:, is_international:, batch_id:, carrier_id:, charge_event:, service_code:, package_code:, voided:, voided_at:, label_format:,
            display_scheme:, label_layout:, trackable:, label_image_id:, carrier_code:, tracking_status:, label_download:, form_download:, insurance_claim:, packages:)
            @label_id = label_id
            @status = status
            @shipment_id = shipment_id
            @ship_date = ship_date
            @created_at = created_at
            @shipment_cost = shipment_cost
            @insurance_cost = insurance_cost
            @tracking_number = tracking_number
            @is_return_label = is_return_label
            @rma_number = rma_number
            @is_international = is_international
            @batch_id = batch_id
            @carrier_id = carrier_id
            @charge_event = charge_event
            @service_code = service_code
            @package_code = package_code
            @voided = voided
            @voided_at = voided_at
            @label_format = label_format
            @display_scheme = display_scheme
            @label_layout = label_layout
            @trackable = trackable
            @label_image_id = label_image_id
            @carrier_code = carrier_code
            @tracking_status = tracking_status
            @label_download = label_download
            @form_download = form_download
            @insurance_claim = insurance_claim
            @packages = packages
          end

          class MonetaryValue
            attr_reader :currency, :amount

            def initialize(currency:, amount:)
              @currency = currency
              @amount = amount
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

          class LabelDownload
            attr_reader :href, :pdf, :png, :zpl

            def initialize(href:, pdf:, png:, zpl:)
              @href = href
              @pdf = pdf
              @png = png
              @zpl = zpl
            end
          end

          class FormDownload
            attr_reader :href, :type

            def initialize(href:, type:)
              @href = href
              @type = type
            end
          end

          class InsuranceClaim
            attr_reader :href, :type

            def initialize(href:, type:)
              @href = href
              @type = type
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
        end
      end
    end
  end
end
