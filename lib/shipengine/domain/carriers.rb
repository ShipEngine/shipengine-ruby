# frozen_string_literal: true

require "shipengine/utils/validate"
require "shipengine/constants"

module ShipEngine
  class Carrier
    attr_reader :code, :name

    # @param code [string] e.g. 'ups' | 'fedex'
    def initialize(code)
      @code = code
      @name = CARRIER_MAP[code]
    end

    # {"carrier_code" => "name"}
    CARRIER_MAP = {
      "ups" => "United Parcel Service",
      "fedex" => "FedEx",
      "usps" => "U.S. Postal Service",
      "stamps_com" => "Stamps.com",
    }.freeze
  end

  class CarrierAccount
    attr_reader :carrier, :account_id, :account_number, :name

    # @param carrier [Carrier]
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

      def list_accounts(config:, carrier_code: nil)
        response = @internal_client.make_request("carrier.listAccounts.v1", { carrierCode: carrier_code }.compact, config)
        accounts = response.result["carrierAccounts"]
        accounts.map do |account|
          CarrierAccount.new(
            carrier_code: account["carrierCode"],
            account_id: account["accountID"],
            account_number: account["accountNumber"],
            name: account["name"]
          )
        end
      end
    end
  end
end
