# frozen_string_literal: true
require "hashie"
require_relative "labels/create_from_rate"
require_relative "labels/create_from_shipment_details"

module ShipEngine
  module Domain
    class Labels
      require "shipengine/constants"

      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      # @param label_id [String]
      # @param params [Hash]
      # @param config [Hash?]
      #
      # @return [ShipEngine::Domain::Labels::CreateFromRate::Response]
      #
      # @see https://shipengine.github.io/shipengine-openapi/#operation/create_label_from_rate
      def create_from_rate(rate_id, params, config)
        response = @internal_client.post("/v1/labels/rates/#{rate_id}", params, config)
        label_api_result = response.body
        mash_result = Hashie::Mash.new(label_api_result)

        shipment_cost = nil
        if mash_result.shipment_cost
          shipment_cost = CreateFromRate::Response::MonetaryValue.new(
            currency: mash_result.shipment_cost.currency,
            amount: mash_result.shipment_cost.amount,
          )
        end

        insurance_cost = nil
        if mash_result.insurance_cost
          insurance_cost = CreateFromRate::Response::MonetaryValue.new(
            currency: mash_result.insurance_cost.currency,
            amount: mash_result.insurance_cost.amount,
          )
        end

        label_download = nil
        if mash_result.label_download
          label_download = CreateFromRate::Response::LabelDownload.new(
            href: mash_result.label_download.href,
            pdf: mash_result.label_download.pdf,
            png: mash_result.label_download.png,
            zpl: mash_result.label_download.zpl
          )
        end

        form_download = nil
        if mash_result.form_download
          form_download = CreateFromRate::Response::FormDownload.new(
            href: mash_result.form_download.href,
            type: mash_result.form_download.type
          )
        end

        insurance_claim = nil
        if mash_result.insurance_claim
          insurance_claim = CreateFromRate::Response::InsuranceClaim.new(
            href: mash_result.insurance_claim.href,
            type: mash_result.insurance_claim.type
          )
        end

        packages = mash_result.packages.map do |package|
          weight = CreateFromRate::Response::Weight.new(
            value: package.weight.value,
            unit: package.weight.unit,
          )

          dimensions = nil
          if package.dimensions
            dimensions = CreateFromRate::Response::Dimensions.new(
              unit: package.dimensions.unit,
              length: package.dimensions["length"],
              width: package.dimensions.width,
              height: package.dimensions.height,
            )
          end

          insured_value = nil
          if package.insured_value
            insured_value = CreateFromRate::Response::MonetaryValue.new(
              currency: package.insured_value.currency,
              amount: package.insured_value.amount,
            )
          end

          label_messages = nil
          if package.label_messages
            label_messages = CreateFromRate::Response::Package::LabelMessages.new(
              reference1: package.label_messages.reference1,
              reference2: package.label_messages.reference2,
              reference3: package.label_messages.reference3
            )
          end

          CreateFromRate::Response::Package.new(
            package_code: package.package_code,
            weight: weight,
            dimensions: dimensions,
            insured_value: insured_value,
            tracking_number: package.tracking_number,
            label_messages: label_messages,
            external_package_id: package.external_package_id
          )
        end

        CreateFromRate::Response.new(
          label_id: mash_result.label_id,
          status: mash_result.status,
          shipment_id: mash_result.shipment_id,
          ship_date: mash_result.ship_date,
          created_at: mash_result.created_at,
          shipment_cost: shipment_cost,
          insurance_cost: insurance_cost,
          tracking_number: mash_result.tracking_number,
          is_return_label: mash_result.is_return_label,
          rma_number: mash_result.rma_number,
          is_international: mash_result.is_international,
          batch_id: mash_result.batch_id,
          carrier_id: mash_result.carrier_id,
          charge_event: mash_result.charge_event,
          service_code: mash_result.service_code,
          package_code: mash_result.package_code,
          voided: mash_result.voided,
          voided_at: mash_result.voided_at,
          label_format: mash_result.label_format,
          display_scheme: mash_result.display_scheme,
          label_layout: mash_result.label_layout,
          trackable: mash_result.trackable,
          label_image_id: mash_result.label_image_id,
          carrier_code: mash_result.carrier_code,
          tracking_status: mash_result.tracking_status,
          label_download: label_download,
          form_download: form_download,
          insurance_claim: insurance_claim,
          packages: packages
        )
      end

      # @param params [Hash]
      # @param config [Hash?]
      #
      # @return [ShipEngine::Domain::Labels::CreateFromShipmentDetails::Response]
      #
      # @see https://shipengine.github.io/shipengine-openapi/#operation/create_label
      def create_from_shipment_details(params, config)
        response = @internal_client.post("/v1/labels", params, config)
        label_api_result = response.body
        mash_result = Hashie::Mash.new(label_api_result)

        shipment_cost = nil
        if mash_result.shipment_cost
          shipment_cost = CreateFromShipmentDetails::Response::MonetaryValue.new(
            currency: mash_result.shipment_cost.currency,
            amount: mash_result.shipment_cost.amount,
          )
        end

        insurance_cost = nil
        if mash_result.insurance_cost
          insurance_cost = CreateFromShipmentDetails::Response::MonetaryValue.new(
            currency: mash_result.insurance_cost.currency,
            amount: mash_result.insurance_cost.amount,
          )
        end

        label_download = nil
        if mash_result.label_download
          label_download = CreateFromShipmentDetails::Response::LabelDownload.new(
            href: mash_result.label_download.href,
            pdf: mash_result.label_download.pdf,
            png: mash_result.label_download.png,
            zpl: mash_result.label_download.zpl
          )
        end

        form_download = nil
        if mash_result.form_download
          form_download = CreateFromShipmentDetails::Response::FormDownload.new(
            href: mash_result.form_download.href,
            type: mash_result.form_download.type
          )
        end

        insurance_claim = nil
        if mash_result.insurance_claim
          insurance_claim = CreateFromShipmentDetails::Response::InsuranceClaim.new(
            href: mash_result.insurance_claim.href,
            type: mash_result.insurance_claim.type
          )
        end

        packages = mash_result.packages.map do |package|
          weight = CreateFromShipmentDetails::Response::Weight.new(
            value: package.weight.value,
            unit: package.weight.unit,
          )

          dimensions = nil
          if package.dimensions
            dimensions = CreateFromShipmentDetails::Response::Dimensions.new(
              unit: package.dimensions.unit,
              length: package.dimensions["length"],
              width: package.dimensions.width,
              height: package.dimensions.height,
            )
          end

          insured_value = nil
          if package.insured_value
            insured_value = CreateFromShipmentDetails::Response::MonetaryValue.new(
              currency: package.insured_value.currency,
              amount: package.insured_value.amount,
            )
          end

          label_messages = nil
          if package.label_messages
            label_messages = CreateFromShipmentDetails::Response::Package::LabelMessages.new(
              reference1: package.label_messages.reference1,
              reference2: package.label_messages.reference2,
              reference3: package.label_messages.reference3
            )
          end

          CreateFromShipmentDetails::Response::Package.new(
            package_code: package.package_code,
            weight: weight,
            dimensions: dimensions,
            insured_value: insured_value,
            tracking_number: package.tracking_number,
            label_messages: label_messages,
            external_package_id: package.external_package_id
          )
        end

        CreateFromShipmentDetails::Response.new(
          label_id: mash_result.label_id,
          status: mash_result.status,
          shipment_id: mash_result.shipment_id,
          ship_date: mash_result.ship_date,
          created_at: mash_result.created_at,
          shipment_cost: shipment_cost,
          insurance_cost: insurance_cost,
          tracking_number: mash_result.tracking_number,
          is_return_label: mash_result.is_return_label,
          rma_number: mash_result.rma_number,
          is_international: mash_result.is_international,
          batch_id: mash_result.batch_id,
          carrier_id: mash_result.carrier_id,
          charge_event: mash_result.charge_event,
          service_code: mash_result.service_code,
          package_code: mash_result.package_code,
          voided: mash_result.voided,
          voided_at: mash_result.voided_at,
          label_format: mash_result.label_format,
          display_scheme: mash_result.display_scheme,
          label_layout: mash_result.label_layout,
          trackable: mash_result.trackable,
          label_image_id: mash_result.label_image_id,
          carrier_code: mash_result.carrier_code,
          tracking_status: mash_result.tracking_status,
          label_download: label_download,
          form_download: form_download,
          insurance_claim: insurance_claim,
          packages: packages
        )
      end
    end
  end
end
