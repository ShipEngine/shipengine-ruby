# frozen_string_literal: true

require 'base58'
require 'securerandom'

module ShipEngine
  module Utils
    class RequestId
      def self.create
        base58_encoded_uuid = Base58.binary_to_base58(SecureRandom.uuid.force_encoding('BINARY'))
        "req_#{base58_encoded_uuid}"
      end
    end
  end
end
