# frozen_string_literal: true

require 'shipengine/utils/validate'
require 'shipengine/constants'

module ShipEngine
  class Carrier
    attr_reader :code, :name

    def initialize(code)
      @code = code
      @name = ::ShipEngine::Constants::Carriers.get_carrier_name_by_code(code)
    end
  end

  class CarrierAccountResult
    attr_reader :carrier, :account_id, :account_number, :name

    # @param carrier_code [String] e.g. 'ups'
    # @param account_id [String] The unique ID that is associated with the current carrier account.
    # @param account_number [String] The account number of the current carrier account.
    # @param name [String] e.g. The account name of the current carrier account.
    def initialize(carrier_code:, account_id:, account_number:, name:)
      @carrier = Carrier.new(carrier_code)
      @account_id = account_id
      @account_number = account_number
      @name = name
    end
  end

  module Domain

    class Carrier
         # @param [ShipEngine::InternalClient] internal_client
      def initialize(internal_client)
        @internal_client = internal_client
      end
      def list_accounts(carrier_code = nil, config)
        @internal_client.make_request('carrier.listAccounts.v1', { carrierCode: carrier_code }, config)
       end
    end
  end
end
