# frozen_string_literal: true

require 'shipengine/client/internal'

module ShipEngine
  module Domain
    class Package
      # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end

      # Track package by package_id OR tracking_number / carrier_code
      # @param [String] package_id - e.g. pkg_123456
      # @return [ShipEngine::Domain::TrackPackageResult]
      def track_by_package_id(package_id)
        ::ShipEngine::Exceptions::FieldValueRequired.assert_field_exists(package_id, 'A package id')

        @internal_client.track_package(package_id: package_id)
      end

      # @param [String] carrier_code - e.g. UPS
      # @param [String]  tracking_number - e.g 1Z9999999999999999
      # @return [ShipEngine::Domain::TrackPackageResult]
      def track_by_number(tracking_number, carrier_code)
        ::ShipEngine::Exceptions::FieldValueRequired.assert_field_exists(tracking_number, 'A tracking number')
        ::ShipEngine::Exceptions::FieldValueRequired.assert_field_exists(carrier_code, 'A carrier code')

        @internal_client.track_package(tracking_number: tracking_number, carrier_code: carrier_code)
      end
    end
  end
end
