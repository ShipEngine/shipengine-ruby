# frozen_string_literal: true

require 'shipengine/version'
require 'shipengine/client/internal'
require 'shipengine/exceptions'

require 'shipengine/domain/package'
require 'shipengine/domain/address'

module ShipEngine
  class Client

    # make domain modules public
    attr_reader :address, :package

    def initialize(api_key:)
      internal_client = ::ShipEngine::InternalClient.new(api_key: api_key)
      @address = ::ShipEngine::Domain::Address.new(internal_client)
      @package = ::ShipEngine::Domain::Package.new(internal_client)
    end
  end
end
