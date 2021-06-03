# frozen_string_literal: true
module ShipEngine
  module Constants
    SIMENGINE_URL = "https://simengine.herokuapp.com/jsonrpc"
    PROD_URL = "https://api.shipengine.com"

    def self.get_simengine_base_url
      ENV["USE_SIMENGINE"] == "true" ? ShipEngine::Constants::SIMENGINE_URL : ShipEngine::Constants::PROD_URL
    end
  end
end
