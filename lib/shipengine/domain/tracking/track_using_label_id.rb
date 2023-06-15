# frozen_string_literal: true

module ShipEngine
  module Domain
    class Tracking
      module TrackUsingLabelId
        class Response
          attr_reader :tracking_number, :status_code, :status_description, :carrier_status_code, :carrier_status_description, :shipped_date, :estimated_delivery_date, :actual_delivery_date, :exception_description, :events

          def initialize(tracking_number:, status_code:, status_description:, carrier_status_code:, carrier_status_description:, shipped_date:, estimated_delivery_date:, actual_delivery_date:, exception_description:, events:) # rubocop:todo Metrics/ParameterLists
            @tracking_number = tracking_number
            @status_code = status_code
            @status_description = status_description
            @carrier_status_code = carrier_status_code
            @carrier_status_description = carrier_status_description
            @shipped_date = shipped_date
            @estimated_delivery_date = estimated_delivery_date
            @actual_delivery_date = actual_delivery_date
            @exception_description = exception_description
            @events = events
          end
        end

        class Event
          attr_reader :occurred_at, :carrier_occurred_at, :description, :city_locality, :state_province, :postal_code, :country_code, :company_name, :signer, :event_code, :latitude, :longitude

          def initialize(occurred_at:, carrier_occurred_at:, description:, city_locality:, state_province:, postal_code:, country_code:, company_name:, signer:, event_code:, latitude:, longitude:) # rubocop:todo Metrics/ParameterLists
            @occurred_at = occurred_at
            @carrier_occurred_at = carrier_occurred_at
            @description = description
            @city_locality = city_locality
            @state_province = state_province
            @postal_code = postal_code
            @country_code = country_code
            @company_name = company_name
            @signer = signer
            @event_code = event_code
            @latitude = latitude
            @longitude = longitude
          end
        end
      end
    end
  end
end
