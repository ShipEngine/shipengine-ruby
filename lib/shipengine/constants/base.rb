# frozen_string_literal: true

module ShipEngine
  module Constants
    # A stub API Key to use in the test suite.
    API_KEY = "baz"

    # Simengine - this is the base_url to use for testing and local development.
    SIMENGINE_URL = "https://simengine.herokuapp.com/jsonrpc"

    # The base_url for the ShipEngine SDK - for use in production environment.
    PROD_URL = "https://api.shipengine.com"

    # Regex pattern to match a valid *ISO-8601* string with timezone.
    VALID_ISO_STRING = /^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?(Z|[+-](?:2[0-3]|[01][0-9]):[0-5][0-9])?$/ # rubocop:disable Layout/LineLength

    # Regex pattern to match a valid *ISO-8601* string with no timezone.
    VALID_ISO_STRING_WITH_NO_TZ = /^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?([+-](?:2[0-3]|[01][0-9]):[0-5][0-9])?$/ # rubocop:disable Layout/LineLength

    # Check env variables to set the appropriate base_url.
    def self.base_url
      ENV["USE_SIMENGINE"] == "true" ? ShipEngine::Constants::SIMENGINE_URL : ShipEngine::Constants::PROD_URL
    end
  end
end
