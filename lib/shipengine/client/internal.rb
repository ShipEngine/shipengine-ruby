# frozen_string_literal: true

require 'faraday_middleware'

module ShipEngine
  class InternalClient
    attr_accessor :connection

    def initialize(api_key:, base_url: 'https://simengine.herokuapp.com/jsonrpc', adapter: Faraday.default_adapter)
      @connection = Faraday.new(url: base_url) do |f|
        f.request :json, :retry
        f.headers = { 'Content-Type' => 'application/json', 'API-Key' => api_key }
        f.response :json, content_type: /\bjson$/
        f.adapter adapter
      end
    end

    def assert_shipengine_rpc_success(body)
      error, request_id = body.values_at('error', 'request_id')
      if error
        message, data = error.values_at('message', 'data')
        source, type, code = data.values_at('source', 'type', 'code')
        raise ShipEngine::Exceptions::ShipEngineErrorDetailed.new(request_id, message, source, type, code)
      end
    end

    # create jsonrpc request has
    def build_jsonrpc_request_body(method, params)
      {
        jsonrpc: '2.0',
        id: '123',
        method: method,
        params: params
      }
    end

    def make_request(method, params)
      response = @connection.send(:post, nil, build_jsonrpc_request_body(method, params))
      body = response.body
      assert_shipengine_rpc_success(body)

      body
      # throw an error if status code is 400 or above.
      # Faraday does not throw errors for 400s -- only 500s!
    rescue Faraday::Error => e
      raise ShipEngine::Exceptions::ShipEngineError, e.message
    end

    def validate_address(address)
      make_request('address/validate', { address: address })
    end

    def track_package_by_id(package_id)
      make_request('package/track', { package_id: package_id })
    end

    def track_package_by_tracking_number(tracking_number, carrier_code)
      make_request('package/track', { tracking_number: tracking_number, carrier_code: carrier_code })
    end
  end
end
