# frozen_string_literal: true

require 'faraday_middleware'
require 'shipengine/utils/request_id'
require 'shipengine/exceptions'
require 'shipengine/version'
require 'logger'

class ShipEngineErrorLogger
  def self.log(data)
    logger = Logger.new($stderr)
    logger.error(data)
  end

  def self.invariant(msg, data)
    ShipEngineErrorLogger.log("INVARIANT Err: #{msg}")
    log(data)
  end
end

module ShipEngine
  class InternalClient
    attr_reader :configuration

    # @param [::ShipEngine::Configuration] configuration
    def initialize(configuration)
      @configuration = configuration
    end

    # @param [String] method - address.validate.v1
    # @param [Hash | Array] params - {street: "123 main street", ...}
    # @param [Hash] opts - options
    # @option opts [String] :api_key
    # @option opts [String] :base_url
    # @option opts [Number] :retries
    # @return body of the shipengine rpc request, or throws error.
    def make_request(method, params, opts = { api_key: nil, base_url: nil, retries: nil,
                                              timeout: nil })
      api_key, base_url, retries, timeout = opts.values_at(:api_key, :base_url, :retries, :timeout)
      config_with_overrides = @configuration.merge(api_key: api_key, base_url: base_url,
                                                   retries: retries, timeout: timeout)
      connection = create_connection(config_with_overrides)

      response = connection.post do |req|
        req.body = build_jsonrpc_request_body(method, params)
      end

      body = response.body

      assert_shipengine_rpc_success(response)

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

    #
    # @param [String] method - e.g. "address.validate.v1"
    # @param [Hash] params
    # @returns [Hash] - JSON:RPC response
    #
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
        ShipEngineErrorLogger.invariant('response body is NOT a hash', [status: response.status, body: response.body])
        raise Exceptions::UnspecifiedError, response
      end

      error, request_id = body.values_at('error', 'request_id')
      return nil unless error

      message, data = error.values_at('message', 'data')
      source, type, code = data.values_at('source', 'type', 'code')
      # rubocop:disable Style/GuardClause
      if type == 'validation'
        raise Exceptions::ValidationError.new(message, code, request_id)
      else
        raise Exceptions::ShipEngineError.new(request_id, message, source, type, code)
      end
      # rubocop:enable Style/GuardClause
    end
  end
end
