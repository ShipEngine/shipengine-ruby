# frozen_string_literal: true

require 'hashie'
require_relative 'tracking/track_using_label_id'
require_relative 'tracking/track_using_carrier_code_and_tracking_number'

module ShipEngine
  module Domain
    class Tracking
      require 'shipengine/constants'

      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      # @param label_id [String]
      # @param config [Hash?]
      #
      # @return [ShipEngine::Domain::Tracking::TrackUsingLabelId::Response]
      #
      # @see https://shipengine.github.io/shipengine-openapi/#operation/validate_address
      def track_using_label_id(label_id, config)
        response = @internal_client.get("/v1/labels/#{label_id}/track", {}, config)
        tracking_api_result = response.body
        mash_result = Hashie::Mash.new(tracking_api_result)

        events = mash_result.events.map do |event|
          TrackUsingLabelId::Event.new(
            occurred_at: event.occurred_at,
            carrier_occurred_at: event.carrier_occurred_at,
            description: event.description,
            city_locality: event.city_locality,
            state_province: event.state_province,
            postal_code: event.postal_code,
            country_code: event.country_code,
            company_name: event.company_name,
            signer: event.signer,
            event_code: event.event_code,
            latitude: event.latitude,
            longitude: event.longitude
          )
        end

        TrackUsingLabelId::Response.new(
          tracking_number: mash_result.tracking_number,
          status_code: mash_result.status_code,
          status_description: mash_result.status_description,
          carrier_status_code: mash_result.carrier_status_code,
          carrier_status_description: mash_result.carrier_status_description,
          shipped_date: mash_result.shipped_date,
          estimated_delivery_date: mash_result.estimated_delivery_date,
          actual_delivery_date: mash_result.actual_delivery_date,
          exception_description: mash_result.exception_description,
          events:
        )
      end

      # @param carrier_code [String]
      # @param tracking_number [String]
      # @param config [Hash?]
      #
      # @return [ShipEngine::Domain::Tracking::TrackUsingCarrierCodeAndTrackingNumber::Response]
      #
      # @see https://shipengine.github.io/shipengine-openapi/#operation/validate_address
      def track_using_carrier_code_and_tracking_number(carrier_code, tracking_number, config)
        response = @internal_client.get('/v1/tracking', { carrier_code:, tracking_number: }, config)
        tracking_api_result = response.body
        mash_result = Hashie::Mash.new(tracking_api_result)

        events = mash_result.events.map do |event|
          TrackUsingCarrierCodeAndTrackingNumber::Event.new(
            occurred_at: event.occurred_at,
            carrier_occurred_at: event.carrier_occurred_at,
            description: event.description,
            city_locality: event.city_locality,
            state_province: event.state_province,
            postal_code: event.postal_code,
            country_code: event.country_code,
            company_name: event.company_name,
            signer: event.signer,
            event_code: event.event_code,
            latitude: event.latitude,
            longitude: event.longitude
          )
        end

        TrackUsingCarrierCodeAndTrackingNumber::Response.new(
          tracking_number: mash_result.tracking_number,
          status_code: mash_result.status_code,
          status_description: mash_result.status_description,
          carrier_status_code: mash_result.carrier_status_code,
          carrier_status_description: mash_result.carrier_status_description,
          shipped_date: mash_result.shipped_date,
          estimated_delivery_date: mash_result.estimated_delivery_date,
          actual_delivery_date: mash_result.actual_delivery_date,
          exception_description: mash_result.exception_description,
          events:
        )
      end
    end
  end
end
