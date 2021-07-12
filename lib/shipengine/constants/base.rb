# frozen_string_literal: true
module ShipEngine
  module Constants
    API_KEY = "baz"
    SIMENGINE_URL = "https://simengine.herokuapp.com/jsonrpc"
    PROD_URL = "https://api.shipengine.com"

    def self.base_url
      ENV["USE_SIMENGINE"] == "true" ? ShipEngine::Constants::SIMENGINE_URL : ShipEngine::Constants::PROD_URL
    end
  end
end
