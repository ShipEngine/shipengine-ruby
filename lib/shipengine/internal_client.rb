# frozen_string_literal: true

require 'faraday_middleware'
require 'shipengine/utils/request_id'
require 'shipengine/exceptions'

module ShipEngine
  class InternalClient
    attr_accessor :connection

    def initialize(api_key:, base_url: 'https://simengine.herokuapp.com/jsonrpc', adapter: Faraday.default_adapter)
      Exceptions::FieldValueRequired.assert_field_exists('A ShipEngine API key', api_key)
      Exceptions::FieldValueRequired.assert_field_exists('base_url', base_url)

      @connection = Faraday.new(url: base_url) do |f|
        f.request :json, :retry
        f.headers = { 'Content-Type' => 'application/json', 'API-Key' => api_key }
        f.response :json, content_type: /\bjson$/
        f.adapter adapter
      end
    end

    def make_request(method, params)
      response = @connection.send(:post, nil, build_jsonrpc_request_body(method, params))
      body = response.body
      assert_shipengine_rpc_success(body)

      body

    # throw an error if status code is 500 or above.
    rescue Faraday::Error => e
      raise Exceptions::ShipEngineError, e.message
    end

    def validate_address(address)
      params = { address: address }
      make_request('address/validate', params)
    end

    def track_package(package_id: nil, tracking_number: nil, carrier_code: nil)
      params = { package_id: package_id, tracking_number: tracking_number, carrier_code: carrier_code }
      make_request('package/track', params)
    end

    private

    # create jsonrpc request has
    def build_jsonrpc_request_body(method, params)
      {
        jsonrpc: '2.0',
        id: Utils::RequestId.create,
        method: method,
        params: params
      }
    end

    def assert_shipengine_rpc_success(body)
      error, request_id = body.values_at('error', 'request_id')
      return nil unless error

      message, data = error.values_at('message', 'data')
      source, type, code = data.values_at('source', 'type', 'code')
      raise Exceptions::ShipEngineErrorDetailed.new(request_id, message, source, type, code)
    end
  end
end
