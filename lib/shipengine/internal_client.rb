# frozen_string_literal: true

require 'faraday_middleware'
require 'shipengine/utils/request_id'
require 'shipengine/exceptions'
require 'shipengine/version'
require 'logger'

class ShipEngineErrorLogger
  def self.log(msg, data)
    logger = Logger.new($stderr)
    logger.log("msg: #{msg}")
    logger.error(data)
  end
end

module ShipEngine
  class InternalClient
    attr_reader :configuration

    # @param [::ShipEngine::Configuration] configuration
    def initialize(configuration)
      @configuration = configuration
    end

    # @param method [String] e.g. `address.validate.v1`
    # @param params [Hash]
    # @param config [Hash?]
    # @option config [String?] :api_key
    # @option config [String?] :base_url
    # @option config [Number?] :retries
    # @option config [Number?] :timeout
    # @return [Hash] - `result` object from JSON-RPC request

    # @example
    #   make_request("address.validate.v1", {address: {...}}, {api_key: "123"}, ...) #=> {...}
    def make_request(method, params, config = { api_key: nil, base_url: nil, retries: nil,
                                                timeout: nil })

      config_with_overrides = @configuration.merge(config)
      connection = create_connection(config_with_overrides)

      response = connection.post do |req|
        req.body = build_jsonrpc_request_body(method, params)
      end

      body = response.body

      assert_shipengine_rpc_success(response)

      body['result']['requestId'] = body['id']
      body['result']
    end

    private

    # @param [::ShipEngine::Configuration] configuration
    # @return [::Faraday::Connection]
    def create_connection(configuration)
      retries = configuration.retries
      base_url = configuration.base_url
      api_key = configuration.api_key
      timeout = configuration.timeout
      Faraday.new(url: base_url, request: { timeout: timeout }) do |f|
        f.request :json
        f.request :retry, { max: retries }
        f.headers = {
          'API-Key' => api_key,
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'User-Agent' => "shipengine-ruby/#{VERSION} (#{RUBY_PLATFORM})"
        }

        f.response :json
        f.adapter Faraday.default_adapter
      end
    end

    # @param [String] method - e.g. "address.validate.v1"
    # @param [Hash] params
    # @return [Hash] - JSON:RPC response
    def build_jsonrpc_request_body(method, params)
      {
        jsonrpc: '2.0',
        id: Utils::RequestId.create,
        method: method,
        params: params
      }
    end

    def assert_shipengine_rpc_success(response)
      body = response.body

      unless body.is_a?(Hash)
        # this should not happen
        ShipEngineErrorLogger.log('response body is NOT a hash', [status: response.status, body: response.body])
        raise Exceptions.create_invariant_error(response)
      end

      error, request_id = body.values_at('error', 'id')
      return nil unless error

      message, data = error.values_at('message', 'data')
      source, type, code = data.values_at('source', 'type', 'code')
      raise Exceptions.create_error_instance_by_type(type: type, message: message, code: code, request_id: request_id, source: source)
    end
  end
end
