# frozen_string_literal: true

# for client class
require "shipengine/internal_client"
require "shipengine/domain"
require "shipengine/configuration"

# just for exporting
require "shipengine/utils/validate"
require "shipengine/version"
require "shipengine/constants"
require "observer"

module ShipEngine
  class Client
    attr_accessor :configuration

    def initialize(api_key, retries: nil, timeout: nil, page_size: nil, base_url: nil)
      @configuration = Configuration.new(
        api_key: api_key,
        retries: retries,
        base_url: base_url,
        timeout: timeout,
        page_size: page_size
      )

      @internal_client = ShipEngine::InternalClient.new(@configuration)
      @addresses = Domain::Addresses.new(@internal_client)
      @carriers = Domain::Carriers.new(@internal_client)
      @labels = Domain::Labels.new(@internal_client)
      @rates = Domain::Rates.new(@internal_client)
      @tracking = Domain::Tracking.new(@internal_client)
    end

    #
    # Validate an array of address
    #
    # @param addresses [Array<ShipEngine::Domain::Addresses::AddressValidation::Request>]
    # @param config [Hash?]
    # @option config [String?] :api_key
    # @option config [String?] :base_url
    # @option config [Number?] :retries
    # @option config [Number?] :timeout
    #
    #
    # @return [Array<ShipEngine::Domain::Addresses::AddressValidation::Response>]
    #
    # @see https://shipengine.github.io/shipengine-openapi/#operation/validate_address
    def validate_addresses(address, config = {})
      @addresses.validate(address, config)
    end

    #
    # List all of the users Carriers
    #
    # @param config [Hash?]
    # @option config [String?] :api_key
    # @option config [String?] :base_url
    # @option config [Number?] :retries
    # @option config [Number?] :timeout
    #
    #
    # @return [ShipEngine::Domain::Carriers::ListCarriers::Response]
    #
    # @see https://shipengine.github.io/shipengine-openapi/#operation/list_carriers
    def list_carriers(config: {})
      @carriers.list_carriers(config: config)
    end

    # Create label from Rate Id
    #
    # @param rate_id [String]
    # @param params [Hash]
    # @param config [Hash]
    # @option config [String?] :api_key
    # @option config [String?] :base_url
    # @option config [Number?] :retries
    # @option config [Number?] :timeout
    #
    # @return [ShipEngine::Domain::Labels::CreateFromRate::Response]
    #
    # @see https://shipengine.github.io/shipengine-openapi/#operation/create_label_from_rate
    def create_label_from_rate(rate_id, params, config = {})
      @labels.create_from_rate(rate_id, params, config)
    end

    # Get Rates with Shipment Details
    #
    # @param Shipment Details [Hash]
    # @param config [Hash]
    # @option config [String?] :api_key
    # @option config [String?] :base_url
    # @option config [Number?] :retries
    # @option config [Number?] :timeout
    #
    # @return [ShipEngine::Domain::Tracking::TrackUsingLabelId::Response]
    #
    def get_rates_with_shipment_details(shipment_details, config = {})
      @rates.get_rates_with_shipment_details(shipment_details, config)
    end

    # Track Package by package id (recommended)
    #
    # @param label_id [String] <description>
    # @param config [Hash]
    # @option config [String?] :api_key
    # @option config [String?] :base_url
    # @option config [Number?] :retries
    # @option config [Number?] :timeout
    #
    # @return [ShipEngine::Domain::Tracking::TrackUsingLabelId::Response]
    #
    def track_using_label_id(label_id, config = {})
      @tracking.track_using_label_id(label_id, config)
    end

    #
    # Track Package by tracking number. Tracking by package_id is preferred [@see #track_package_by_id]
    # @param tracking_number [String] <description>
    # @param config [Hash]
    # @option config [String?] :api_key
    # @option config [String?] :base_url
    # @option config [Number?] :retries
    # @option config [Number?] :timeout
    #
    # @return [ShipEngine::Domain::Tracking::TrackUsingCarrierCodeAndTrackingNumber::Response]
    #
    def track_using_carrier_code_and_tracking_number(carrier_code, tracking_number, config = {})
      @tracking.track_using_carrier_code_and_tracking_number(carrier_code, tracking_number, config)
    end
  end
end
