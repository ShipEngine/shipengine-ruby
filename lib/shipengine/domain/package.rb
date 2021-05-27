# frozen_string_literal: true

require 'shipengine/utils/validate'

module ShipEngine
  module Domain
    class Package
      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      # Track package by package_id OR tracking_number / carrier_code
      # @param [String] package_id - e.g. pkg_123456
      # @return [ShipEngine::Domain::Package::TrackPackageResult]
      def track_by_id(package_id, config = {})
        Utils::Validate.not_nil_or_empty_str(package_id, 'A package id')
        @internal_client.make_request('package.track.v1', { packageID: package_id }, config)
      end

      # @param [String] carrier_code - e.g. UPS
      # @param [String]  tracking_number - e.g 1Z9999999999999999
      # @return [ShipEngine::Domain::Package::TrackPackageResult]
      def track_by_tracking_number(tracking_number, carrier_code, config = {})
        Utils::Validate.not_nil_or_empty_str(tracking_number, 'A tracking number')
        Utils::Validate.not_nil_or_empty_str(carrier_code, 'A carrier code')
        @internal_client.make_request('package.track.v1',
          { trackingNumber: tracking_number, carrierCode: carrier_code }, config)
      end
    end
  end
end
