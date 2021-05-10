# frozen_string_literal: true

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
      def track_by_id(package_id, opts = {})
        ::ShipEngine::Exceptions::FieldValueRequired.assert_field_exists(package_id, 'A package id')

        @internal_client.make_request('package.track.v1', { packageID: package_id }, opts)
      end

      # @param [String] carrier_code - e.g. UPS
      # @param [String]  tracking_number - e.g 1Z9999999999999999
      # @return [ShipEngine::Domain::Package::TrackPackageResult]
      def track_by_tracking_number(tracking_number, carrier_code, opts = {})
        ::ShipEngine::Exceptions::FieldValueRequired.assert_field_exists(tracking_number, 'A tracking number')
        ::ShipEngine::Exceptions::FieldValueRequired.assert_field_exists(carrier_code, 'A carrier code')

        @internal_client.make_request('package.track.v1', { trackingNumber: tracking_number, carrierCode: carrier_code }, opts)
      end
    end
  end
end
