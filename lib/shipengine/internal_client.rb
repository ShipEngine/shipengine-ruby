# frozen_string_literal: true

require 'faraday_middleware'
require 'shipengine/utils/request_id'
require 'shipengine/exceptions'
require 'shipengine/version'

module ShipEngine
  class InternalClient
    attr_reader :connection, :configuration

    def initialize(configuration, adapter: Faraday.default_adapter)
      configuration.validate()
      @configuration = configuration

      @connection = Faraday.new do |f|
        f.request :json
        f.request :retry, {max: @retries}
        f.headers = {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'User-Agent' => "shipengine-ruby/#{VERSION} (#{RUBY_PLATFORM})"
        }
        f.response :json, content_type: /\bjson$/
        f.adapter adapter
      end
    end

    def make_request(method, params)
      additional_headers = {'API-Key' => @configuration.api_key}
      response = @connection.post(@configuration.base_url, build_jsonrpc_request_body(method, params), additional_headers)
      body = response.body
      assert_shipengine_rpc_success(body)
      body

    # throw an error if status code is 500 or above.
    rescue Faraday::Error => e
      raise Exceptions::ShipEngineError, e.message
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
      raise Exceptions::ShipEngineError.new(request_id, message, source, type, code)
    end
  end
end
