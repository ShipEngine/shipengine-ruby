# frozen_string_literal: true

require 'faraday_middleware'

module ShipEngine
  class PlatformClient
    attr_accessor :connection

    def initialize(api_key:, base_url: 'https://simengine.herokuapp.com/jsonrpc', adapter: Faraday.default_adapter)
      @connection = Faraday.new(url: base_url) do |f|
        f.request :json, :retry
        f.headers = { 'Content-Type' => 'application/json', 'API-Key' => api_key }
        f.response :json, content_type: /\bjson$/
        f.adapter adapter
      end
    end

    def assert_no_platform_errors(response)
      # puts response.inspect
      body = response.body
      error = body['error'] || {}
      data = error['data']
      return unless data
        raise ShipEngine::Exceptions::ShipEngineErrorDetailed.new(body['id'], error['message'], data) unless data.nil?
      end
    end

    # create jsonrpc request has
    def create_jsonrpc_request_body(method, params)
      {
        jsonrpc: '2.0',
        id: '123',
        method: method,
        params: params
      }
    end

    def make_request(method, params)
      response = @connection.send(:post, nil, create_jsonrpc_request_body(method, params))
      assert_no_platform_errors(response)
      response.body
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
