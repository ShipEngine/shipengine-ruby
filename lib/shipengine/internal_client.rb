# frozen_string_literal: true

require 'faraday_middleware'
require 'shipengine/utils/request_id'
require 'shipengine/exceptions'
require 'shipengine/version'

module ShipEngine
  class InternalClient
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def create_connection(configuration)
      retries = configuration.retries
      base_url = configuration.base_url
      api_key = configuration.api_key

      Faraday.new(url: base_url) do |f|
        f.request :json
        f.request :retry, { max: retries }
        f.headers = {
          'API-Key' => api_key,
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'User-Agent' => "shipengine-ruby/#{VERSION} (#{RUBY_PLATFORM})"
        }
        f.response :json, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
      end
    end

    def make_request(method, params, options = {})
      api_key, base_url, retries = options.values_at(:api_key, :base_url, :retries)
      config_with_overrides = @configuration.merge(api_key: api_key, base_url: base_url, retries: retries)
      connection = create_connection(config_with_overrides)
      response = connection.send(:post, nil, build_jsonrpc_request_body(method, params))
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
