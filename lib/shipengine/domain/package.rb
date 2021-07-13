# frozen_string_literal: true

require "shipengine/utils/validate"
require "shipengine/utils/pretty_print"

module ShipEngine
  class TrackPackageLocationCoordinates
    include ::ShipEngine::Utils::PrettyPrint
    attr_reader :latitude, :longitude

    def initialize(latitude:, longitude:)
      @latitude = latitude
      @longitude = longitude
    end
  end

  class TrackPackageShipment
    include ::ShipEngine::Utils::PrettyPrint
    attr_reader(
      :carriers,
      :config,
      :shipment_id,
      :carrier_account_id,
      :carrier_account,
      :carrier,
      :estimated_delivery_date,
      :actual_delivery_date
    )

    def initialize(
      carrier:,
      shipment_id:,
      carrier_account:,
      carrier_account_id:,
      estimated_delivery_date:,
      actual_delivery_date:,
      config:,
      carriers:
    )
      @carriers = carriers
      @config = config
      @shipment_id = !shipment_id.nil? ? shipment_id : nil
      @carrier_account_id = carrier_account_id

      unless carrier_account.nil?
        @carrier_account = get_carrier_account(carrier_account, @carrier_account_id)
      end

      @carrier = carrier
      @estimated_delivery_date = estimated_delivery_date
      @actual_delivery_date = actual_delivery_date
    end

    private

    def get_carrier_account(carrier, account_id)
      target_carrier = []

      carrier_accounts = @carriers.list_accounts(config: @config, carrier_code: carrier)
      carrier_accounts.each do |n|
        if account_id == n.account_id
          target_carrier << n
        end
      end
      target_carrier[0]
    end
  end

  class TrackPackageLocation
    include ::ShipEngine::Utils::PrettyPrint
    attr_reader :postal_code, :country_code, :city_locality, :coordinates

    def initialize(postal_code:, country_code:, city_locality:, coordinates:)
      @postal_code = postal_code
      @country_code = country_code
      @city_locality = city_locality
      @coordinates = coordinates
    end
  end

  class TrackPackageEvent
    include ::ShipEngine::Utils::PrettyPrint
    attr_reader :datetime, :carrier_datetime, :status, :description, :carrier_status_code, :carrier_detail_code, :signer, :location

    def initialize(datetime:, carrier_datetime:, status:, description:, carrier_status_code:, carrier_detail_code:, signer:, location:)
      @datetime = datetime
      @carrier_datetime = carrier_datetime
      @status = status
      @description = description
      @carrier_status_code = carrier_status_code
      @carrier_detail_code = carrier_detail_code
      @signer = signer
      @location = location
    end
  end

  class TrackPackageWeight
    include ::ShipEngine::Utils::PrettyPrint
    attr_reader :unit, :value

    def initialize(unit:, value:)
      @unit = unit
      @value = value
    end
  end

  class TrackPackageDimensions
    include ::ShipEngine::Utils::PrettyPrint
    attr_reader :unit, :height, :length, :width

    def initialize(unit:, height:, length:, width:)
      @unit = unit
      @height = height
      @width = width
      @length = length
    end
  end

  class TrackPackagePackage
    include ::ShipEngine::Utils::PrettyPrint
    attr_reader :package_id, :tracking_number, :tracking_url, :weight, :dimensions

    # @param tracking_number [String]
    # @param tracking_url [String]
    # @param weight [Number]
    # @param dimensions [::TrackPackageDimensions]
    #
    def initialize(package_id:, tracking_number:, tracking_url:, weight:, dimensions:)
      @package_id = package_id
      @tracking_number = tracking_number
      @tracking_url = URI(tracking_url)
      @weight = weight
      @dimensions = dimensions
    end
  end

  class TrackPackageResult
    include ::ShipEngine::Utils::PrettyPrint
    attr_reader :package, :shipment, :events, :latest_event, :errors

    def initialize(
      package:,
      shipment:,
      events:,
      latest_event:,
      errors:,
      has_errors:
    )
      @shipment = shipment
      @package = package
      @events = events
      @latest_event = latest_event
      @errors = errors
      @has_errors = has_errors
    end

    def has_errors?
      @has_errors
    end
  end

  def self.get_actual_delivery_date(events)
    # delivered_events = events.filter { |e| e.status.downcase == "delivered" }
    events[-1].datetime
  end

  def self.map_event(event)
    loc = event["location"]
    coordinates = loc && loc["coordinates"]
    TrackPackageEvent.new(
      datetime: Date.iso8601(event["timestamp"]),
      carrier_datetime: Date.iso8601(event["carrierTimestamp"]),
      status: event["status"],
      description: event["description"],
      carrier_status_code: event["carrierStatusCode"],
      carrier_detail_code: event["carrierDetailCode"],
      signer: event["signer"],
      location: loc && TrackPackageLocation.new(
        city_locality: loc["cityLocality"],
        postal_code: loc["postalCode"],
        country_code: loc["countryCode"],
        coordinates: coordinates && TrackPackageLocationCoordinates.new(
          latitude: coordinates["latitude"],
          longitude: coordinates["longitude"]
        )
      )
    )
  end

  def self.map_track_package_result(result, config, carriers)
    shipment, package, events, _request_id = result.values_at("shipment", "package", "events", "id")
    weight = package["weight"]
    dimensions = package["dimensions"]
    events = events.map { |e| map_event(e) }
    errors = events.select { |event| event.status == "Exception" }

    TrackPackageResult.new(
      latest_event: events[-1],
      package: TrackPackagePackage.new(
        package_id: package["packageID"],
        tracking_number: package["trackingNumber"],
        tracking_url: package["trackingURL"],
        weight: weight && TrackPackageWeight.new(
          value: weight["value"],
          unit: weight["unit"]
        ),
        dimensions: dimensions && TrackPackageDimensions.new(
          length: dimensions["length"],
          width: dimensions["width"],
          height: dimensions["height"],
          unit: dimensions["unit"]
        )
      ),

      errors: errors,
      has_errors: !errors.empty?,

      shipment: shipment && TrackPackageShipment.new(
        carrier: !shipment["carrierCode"].nil? ? ::ShipEngine::Carrier.new(shipment["carrierCode"]) : nil,
        carrier_account_id: !shipment["carrierAccountID"].nil? ? shipment["carrierAccountID"] : nil,
        carrier_account: !shipment["carrierCode"].nil? ? shipment["carrierCode"] : nil,
        shipment_id: !shipment["shipmentID"].nil? ? shipment["shipmentID"] : nil,
        estimated_delivery_date: Date.iso8601(shipment["estimatedDelivery"]),
        actual_delivery_date: get_actual_delivery_date(events),
        config: config,
        carriers: carriers
      ),
      events: events
    )
  end

  module Domain
    class Package
      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client, carriers)
        @internal_client = internal_client
        @carriers = carriers
      end

      # Track package by package_id OR tracking_number / carrier_code
      # @param [String] package_id - e.g. pkg_123456
      # @return [ShipEngine::Domain::Package::TrackPackageResult]
      def track_by_id(package_id, config = {})
        Utils::Validate.not_nil_or_empty_str(package_id, "A package id")
        response = @internal_client.make_request("package.track.v1", { packageID: package_id }, config)
        ::ShipEngine.map_track_package_result(response.result, config, @carriers)
      end

      # TrackPackageResult.new(package:  )

      # @param [String] carrier_code - e.g. UPS
      # @param [String]  tracking_number - e.g 1Z9999999999999999
      # @return [ShipEngine::Domain::Package::TrackPackageResult]
      def track_by_tracking_number(tracking_number, carrier_code, config = {})
        Utils::Validate.not_nil_or_empty_str(tracking_number, "A tracking number")
        Utils::Validate.not_nil_or_empty_str(carrier_code, "A carrier code")
        response = @internal_client.make_request("package.track.v1", { trackingNumber: tracking_number, carrierCode: carrier_code }, config)
        ::ShipEngine.map_track_package_result(response.result, config, @carriers)
      end
    end
  end
end
