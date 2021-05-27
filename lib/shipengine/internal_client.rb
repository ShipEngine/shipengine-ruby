# frozen_string_literal: true

require 'shipengine/utils/request_id'
require 'shipengine/exceptions'
require 'shipengine/version'
require 'logger'
require 'faraday_middleware'
require 'json'
require 'observer'

class ShipEngineErrorLogger
  def self.log(msg, data = nil)
    logger = Logger.new($stderr)
    logger.error([msg, data])
  end
end

module ShipEngine
  module CustomMiddleware
    # This transforms the `retryAfter` field from our JSON-RPC server to an HTTP header, so this client
    # can use the standard retry middleware from faraday-middleware.
    class RetryAfter < Faraday::Middleware
      attr_reader :retry_attempt

      def initialize(app)
        super(app)
        @retry_attempt = 0
        @app = app
      end

      def on_complete(env)
        body = env[:body]
        status = env[:status]
        return env unless (status == 429) && body.is_a?(Hash) && body['error']

        # ShipEngineErrorLogger.log('Retrying...attempt: #{ @retry_attempt}')
        env[:response_headers]['Retry-After'] ||= body.dig('error', 'data', 'retryAfter').to_s
        @retry_attempt += 1
        env[:attempts] = @retry_attempt
        env
      end
    end
  end

  class InternalClientResponseSuccess
    attr_reader :result, :request_id

    # @param result [Hash | Array]
    # @param request_id [String]
    def initialize(result:, request_id:)
      @result = result
      @request_id = request_id
    end
  end

  class InternalClient
    include Observable
    attr_reader :configuration

    # @param [::ShipEngine::Configuration] configuration
    def initialize(configuration, network_observer)
      Faraday::Request.register_middleware(retry_after: CustomMiddleware::RetryAfter)
      @configuration = configuration

      network_observer&.new(self)
    end

    # @param method [String] e.g. `address.validate.v1`
    # @param params [Hash]
    # @param config [Hash?]
    # @option config [String?] :api_key
    # @option config [String?] :base_url
    # @option config [Number?] :retries
    # @option config [Number?] :timeout
    # @return [::InternalClientResponseSuccess]
    # @example
    #   make_request("address.validate.v1", {address: {...}}, {api_key: "123"}, ...) #=> {...}
    def make_request(method, params, config = { api_key: nil, base_url: nil, retries: nil,
                                                timeout: nil })

      config_with_overrides = @configuration.merge(config)
      connection = create_connection(config_with_overrides)

      response = connection.post do |req|
        req.body = build_jsonrpc_request_body(method, params)
      end

      assert_shipengine_rpc_success(response, config_with_overrides)

      result, id = response.body.values_at('result', 'id')
      InternalClientResponseSuccess.new(result: result, request_id: id)
    end

    private

    # @param config [::ShipEngine::Configuration]
    # @return [::Faraday::Connection]
    def create_connection(config)
      retries = config.retries
      base_url = config.base_url
      api_key = config.api_key
      timeout = config.timeout

      Faraday.new(url: base_url, request: { timeout: timeout }) do |f|
        f.request :json
        f.request :retry, {
          max: retries,
          retry_block: lambda { |env, _options, _r, _exc|
            changed
            notify_observers({ type: 'retry', attempts: env[:attempts] })
          },
          retry_statuses: [429], # even though this seems self-evident, this field is neccessary for Retry-After to be respected.
          methods: Faraday::Request::Retry::IDEMPOTENT_METHODS + [:post] # :post is not a "retry-able request by default"
        }
        f.request :retry_after # should go after :retry
        f.headers = {
          'API-Key' => api_key,
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'User-Agent' => "shipengine-ruby/#{VERSION} (#{RUBY_PLATFORM})"
        }
        f.response :json
      end
    end

    # @param method [String] e.g. "address.validate.v1"
    # @param params [Hash]
    # @return [Hash] - JSON:RPC response
    def build_jsonrpc_request_body(method, params)
      {
        jsonrpc: '2.0',
        id: Utils::RequestId.create,
        method: method,
        params: params
      }
    end

    # @param response [::Faraday::Response]
    # @param config [::ShipEngine::Configuration]
    def assert_shipengine_rpc_success(response, config)
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
      raise Exceptions.create_error_instance(type: type, message: message, code: code, request_id: request_id, source: source, config: config)
    end
  end
end
