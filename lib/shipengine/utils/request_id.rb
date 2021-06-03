# frozen_string_literal: true

require "securerandom"
require_relative "base58"

module ShipEngine
  module Utils
    class RequestId
      # @return [String] req_abcd123456789
      def self.create
        base58_encoded_uuid = Base58.binary_to_base58(SecureRandom.uuid.force_encoding("BINARY"))
        "req_#{base58_encoded_uuid}"
      end
    end
  end
end
