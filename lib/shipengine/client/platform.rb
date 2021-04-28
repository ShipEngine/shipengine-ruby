# frozen_string_literal: true

require 'faraday_middleware'

module ShipEngine
  class PlatformClient
    attr_accessor :connection

    def initialize(api_key:, base_url: 'https://platform.shipengine.com/v1', adapter: Faraday.default_adapter)
      @connection = Faraday.new(url: base_url) do |f|
        f.request :json, :retry
        f.headers = { 'Content-Type' => 'application/json', 'API-Key' => api_key }
        f.response :json, content_type: /\bjson$/
        f.adapter adapter
      end
    end

    def make_request(method:, route:, body: nil, params: nil)
      method_lc = method.downcase.to_sym
      data = method_lc == :get ? params : body
      response = @connection.send(method_lc, route, data)
      response.body


    # Faraday does not throw errors for 400s -- only 500s!
    rescue Faraday::Error => e
      raise ShipEngine::Exceptions::ShipEngineError, e.message
    end
  end
end
