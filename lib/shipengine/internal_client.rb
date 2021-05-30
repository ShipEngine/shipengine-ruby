# frozen_string_literal: true

require "shipengine/utils/request_id"
require "shipengine/exceptions"
require "shipengine/version"
require "logger"
require "faraday_middleware"
require "json"

class ShipEngineErrorLogger
  def self.log(msg, data = nil)
    logger = Logger.new($stderr)
    logger.error([msg, data])
  end
end

module ShipEngine
  module CustomMiddleware
    class Utils
      class << self
        # @param datetime [Time]
        # @return [Float] - time elapsed in SECONDS
        def calculate_time_elapsed_in_sec(datetime)
          ((Time.now - datetime) * 24 * 60 * 60).to_f
        end

        def get_retry_after(headers)
          headers["Retry-After"]
        end

        def get_retry_after_from_body(body)
          body.dig("error", "data", "retryAfter")
        end

        def set_retry_after(headers, value)
          headers["Retry-After"] = value
        end

        def assert_retry_after(timeout, retry_after, request_id)
          if (timeout / 1000) < (retry_after || 0)
            raise ::ShipEngine::Exceptions::TimeoutError.new(message: "The request took longer than the #{timeout} milliseconds allowed",
              request_id: request_id)
          end
        end

        # @param str [String]
        # @return [Hash] (or default)
        def safe_json_parse(str, default = nil)
          JSON.parse(str)
        rescue ::StandardError => e
          ShipEngineErrorLogger.log("JSON parse error", e)
          default
        end
      end
    end

    # This transforms the `retryAfter` field from our JSON-RPC server to an HTTP header, so this client
    # can use the standard retry middleware from faraday-middleware.
    class AddRetryAfterHeader < Faraday::Middleware
      def initialize(app)
        super(app)
        @retries = 0
        @app = app
      end

      def on_complete(env)
        body = env[:body]
        status = env[:status]
        return env unless (status == 429) && body.is_a?(Hash) && body["error"]

        # ShipEngineErrorLogger.log('Retrying...attempt: #{ @retries}')
        env[:response_headers]["Retry-After"] ||= Utils.get_retry_after_from_body(body).to_s
        @retries += 1
        env[:retries] = @retries
        env
      end
    end

    # Middleware that exists to emit a RequestSentEvent
    class RequestSentEmitter < Faraday::Middleware
      def initialize(app, subscriber:, timeout:)
        super(app)
        @app = app
        @subscriber = subscriber
        @timeout = timeout
      end

      # @param env [Faraday::Env]
      # @return [::ShipEngine::Subscriber::RequestSentEvent]
      def build_request_sent_event(env)
        parsed_request_body = Utils.safe_json_parse(env[:request_body])
        url = env.url
        method = parsed_request_body["method"] if parsed_request_body
        request_id = parsed_request_body["id"] if parsed_request_body
        retries = env[:retries]
        ::ShipEngine::Subscriber::RequestSentEvent.new(
          message: "Calling the ShipEngine #{method} API at #{url}",
          request_id: request_id,
          body: parsed_request_body,
          url: url,
          headers: env,
          retries: retries || 0,
          timeout: @timeout
        )
      end

      # @param env [Faraday::Env]
      # See: https://github.com/lostisland/faraday/blob/main/docs/middleware/custom.md
      def on_request(env)
        event = build_request_sent_event(env)
        @subscriber&.on_request_sent(event)

        # Store initial event date time in env so it can be used to calculate total time elapsed by the ResponseRecievedEmitter middleware.
        # first_event_datetime is the timestamp of the _initial_ request made by the client, i.e retries are ignored.
        env[:first_event_datetime] = event.datetime unless env[:retries]

        # Fun fact, "app.call" returns  an on_complete method that contains a block that contains response information.
        # (See: https://github.com/lostisland/faraday/blob/main/docs/middleware/custom.md)
        # Tried using that block to emit a ResponseReceivedEvent instead of creating a separate response middleware...
        # However, I encountered a _bug?_ where the initial response_body and response_headers would always be nil
        # (though any subsequent retry calls had the information populated as usual.)
      end
    end

    # DX-1492

    # Middleware that exists to emit a ResponseReceivedEvent
    class ResponseRecievedEmitter < Faraday::Middleware
      def initialize(app, subscriber:, timeout:)
        super(app)
        @app = app
        @subscriber = subscriber
        @timeout = timeout
      end

      # @param env [Faraday::Env]
      # @return [::ShipEngine::Subscriber::ResponseReceivedEvent]
      def build_response_received_event(env)
        parsed_request_body = Utils.safe_json_parse(env[:request_body])
        parsed_response_body = Utils.safe_json_parse(env[:response_body])
        status =  env[:status]
        headers = env[:response_headers]
        method, request_id = parsed_request_body.values_at("method", "id") if parsed_request_body
        url = env[:url]
        retries = env[:retries]
        elapsed_sec = Utils.calculate_time_elapsed_in_sec(env[:first_event_datetime]) unless env[:first_event_datetime].nil?
        # puts "#{elapsed_sec} seconds have elapsed since request first made"
        ::ShipEngine::Subscriber::ResponseReceivedEvent.new(
          message: "Received an HTTP #{status} response from the ShipEngine #{method} API",
          request_id: request_id,
          status_code: status,
          body: parsed_response_body,
          url: url,
          headers: headers,
          retries: retries || 0,
          elapsed: elapsed_sec
        )
      end

      # @param env [Faraday::Env]
      def on_complete(env)
        event = build_response_received_event(env)
        @subscriber&.on_response_received(event)

        # wait until event has been dispatched to throw error.
        retry_after = Utils.get_retry_after_from_body(event.body)
        Utils.assert_retry_after(@timeout, retry_after, event.request_id)
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
    attr_reader :configuration

    # @param [::ShipEngine::Configuration] configuration
    def initialize(configuration)
      Faraday::Request.register_middleware(retry_after_header: CustomMiddleware::AddRetryAfterHeader)
      Faraday::Request.register_middleware(request_sent: CustomMiddleware::RequestSentEmitter)
      Faraday::Response.register_middleware(response_received: CustomMiddleware::ResponseRecievedEmitter)
      @configuration = configuration
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
    def make_request(method, params, config = {})
      config_with_overrides = @configuration.merge(config)
      connection = create_connection(config_with_overrides)

      response = connection.post do |req|
        req.body = build_jsonrpc_request_body(method, params)
      end

      assert_shipengine_rpc_success(response, config_with_overrides)

      result, id = response.body.values_at("result", "id")
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
      subscriber = config.subscriber

      Faraday.new(url: base_url, request: { timeout: timeout / 1000 }) do |f|
        f.request(:json)
        f.request(:retry, {
          max: retries,
          retry_statuses: [429], # even though this seems self-evident, this field is neccessary for Retry-After to be respected.
          methods: Faraday::Request::Retry::IDEMPOTENT_METHODS + [:post], # :post is not a "retry-able request by default"
        })
        f.request(:retry_after_header) # should go after :retry
        f.request(:request_sent, subscriber: subscriber, timeout: timeout)
        f.headers = {
          "API-Key" => api_key,
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "User-Agent" => "shipengine-ruby/#{VERSION} (#{RUBY_PLATFORM})",
        }
        f.response(:json)
        f.response(:response_received, subscriber: subscriber, timeout: timeout)
      end
    end

    # @param method [String] e.g. "address.validate.v1"
    # @param params [Hash]
    # @return [Hash] - JSON:RPC response
    def build_jsonrpc_request_body(method, params)
      {
        jsonrpc: "2.0",
        id: Utils::RequestId.create,
        method: method,
        params: params,
      }
    end

    # @param response [::Faraday::Response]
    # @param config [::ShipEngine::Configuration]
    def assert_shipengine_rpc_success(response, config)
      body = response.body
      unless body.is_a?(Hash)
        # this should not happen
        ShipEngineErrorLogger.log("response body is NOT a hash", [status: response.status, body: response.body])
        raise Exceptions.create_invariant_error(response)
      end

      error, request_id = body.values_at("error", "id")
      return nil unless error

      message, data = error.values_at("message", "data")
      source, type, code = data.values_at("source", "type", "code")
      raise Exceptions.create_error_instance(type: type, message: message, code: code, request_id: request_id, source: source, config: config)
    end
  end
end
