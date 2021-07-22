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

    # def list_carrier_accounts(carrier_code: nil, config: {})
    #   with_emit_error(config[:emitter]) do
    #     @carriers.list_accounts(carrier_code: carrier_code, config: config)
    #   end
    # end

    # # Track package by package id (recommended)
    # #
    # # @param tracking_number [String] <description>
    # # @param config [Hash]
    # # @option config [String?] :api_key
    # # @option config [String?] :base_url
    # # @option config [Number?] :retries
    # # @option config [Number?] :timeout
    # #
    # # @return [::ShipEngine::TrackPackageResult]
    # #
    # def track_package_by_id(package_id, config = {})
    #   with_emit_error(config[:emitter]) do
    #     @package.track_by_id(package_id, config)
    #   end
    # end

    # #
    # # Track package by tracking number. Tracking by package_id is preferred [@see #track_package_by_id]
    # # @param tracking_number [String] <description>
    # # @param config [Hash]
    # # @option config [String?] :api_key
    # # @option config [String?] :base_url
    # # @option config [Number?] :retries
    # # @option config [Number?] :timeout
    # #
    # # @return [::ShipEngine::TrackPackageResult]
    # #
    # def track_package_by_tracking_number(tracking_number, carrier_code, config = {})
    #   with_emit_error(config[:emitter]) do
    #     @package.track_by_tracking_number(tracking_number, carrier_code, config)
    #   end
    # end
  end
end
