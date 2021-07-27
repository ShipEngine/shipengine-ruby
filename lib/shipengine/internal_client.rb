# frozen_string_literal: true
Dir[File.expand_path("../../faraday/*.rb", __FILE__)].each { |f| require f }
require "shipengine/utils/request_id"
require "shipengine/utils/user_agent"
require "faraday_middleware"
require "json"

# frozen_string_literal: true
module ShipEngine
  class InternalClient
    attr_reader :configuration

    # @param [::ShipEngine::Configuration] configuration
    def initialize(configuration)
      @configuration = configuration
    end

    # Perform an HTTP GET request
    def get(path, options = {}, config = {})
      request(:get, path, options, config)
    end

    # Perform an HTTP POST request
    def post(path, options = {}, config = {})
      request(:post, path, options, config)
    end

    # Perform an HTTP PUT request
    def put(path, options = {}, config = {})
      request(:put, path, options, config)
    end

    # Perform an HTTP DELETE request
    def delete(path, options = {}, config = {})
      request(:delete, path, options, config)
    end

    private

    # @param config [::ShipEngine::Configuration]
    # @return [::Faraday::Connection]
    def create_connection(config)
      retries = config.retries
      base_url = config.base_url
      api_key = config.api_key
      timeout = config.timeout

      Faraday.new(url: base_url) do |conn|
        conn.headers = {
          "API-Key" => api_key,
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "User-Agent" => Utils::UserAgent.new.to_s,
        }

        conn.options.timeout = timeout / 1000
        conn.request(:json) # auto-coerce bodies to json
        conn.request(:retry, {
          max: retries,
          retry_statuses: [429], # even though this seems self-evident, this field is neccessary for Retry-After to be respected.
          methods: Faraday::Request::Retry::IDEMPOTENT_METHODS + [:post], # :post is not a "retry_attempt-able request by default"
          exceptions: [ShipEngine::Exceptions::RateLimitError],
          retry_block: proc { |env, _opts, _retries, _exception|
            env.request_headers["Retries"] = config.retries.to_s
          },
        })

        conn.use(FaradayMiddleware::RaiseHttpException)
        # conn.request(:retry_after_header) # should go after :retry_attempt
        # conn.request(:request_sent, config)
        conn.response(:json)
      end
    end

    # Perform an HTTP request
    def request(method, path, options, config)
      config_with_overrides = @configuration.merge(config)

      response = create_connection(config_with_overrides).send(method) do |request|
        case method
        when :get, :delete
          request.url(URI.encode(path), options)
        when :post, :put
          request.path = URI.encode(path)
          request.body = options unless options.empty?
        end
      end
      response
    end
  end
end
