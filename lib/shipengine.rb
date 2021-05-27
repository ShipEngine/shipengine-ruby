# frozen_string_literal: true

# for client class
require 'shipengine/internal_client'
require 'shipengine/domain'

# just for exporting
require 'shipengine/version'
require 'shipengine/exceptions'
require 'shipengine/utils/validate'
require 'shipengine/constants'
require 'observer'

module ShipEngine
  class Configuration
    attr_accessor :api_key, :retries, :base_url, :timeout, :page_size, :subscriber

    def initialize(api_key:, retries: nil, timeout: nil, page_size: nil, base_url: nil, subscriber: nil)
      @api_key = api_key
      @base_url = base_url || (ENV['USE_SIMENGINE'] == 'true' ? 'https://simengine.herokuapp.com/jsonrpc' : 'https://api.shipengine.com')
      @retries = retries || 1
      @timeout = timeout || 5 # https://github.com/lostisland/faraday/issues/708
      @page_size = page_size || 50
      @subscriber = subscriber || Subscriber::EventEmitter.new
      validate
    end

    # @param opts [Hash] the options to create a message with.
    # @option opts [String] :ap The subject
    # @option opts [String] :from ('nobody') From address
    # @option opts [String] :to Recipient email
    # @option opts [String] :body ('') The email's body
    def merge(config)
      copy = clone
      copy.api_key = config[:api_key] if config.key?(:api_key)
      copy.base_url = config[:base_url] if config.key?(:base_url)
      copy.retries =  config[:retries] if config.key?(:retries)
      copy.timeout =  config[:timeout] if config.key?(:timeout)
      copy.page_size = config[:page_size] if config.key?(:page_size)
      copy.subscriber = config[:subscriber] if config.key?(:subscriber)
      copy.validate
      copy
    end

    # since the fields in the class are mutable, we should be able to validate them at any time.
    protected

    def validate
      Utils::Validate.str('A ShipEngine API key', @api_key)
      Utils::Validate.str('Base URL', @base_url)
      Utils::Validate.non_neg_int('Retries', @retries)
      Utils::Validate.positive_int('Timeout', @timeout)
      Utils::Validate.positive_int('Page size', @page_size)
    end
  end

  module Subscriber
    class Event
      require 'date'
      attr_reader :datetime, :type, :message
      def initialize(type:, message:)
        @type = type
        @message = message
        @datetime = DateTime.now
      end
    end

    class EventType
      RESPONSE_RECEIVED = 'response_received',
      REQUEST_SENT = 'request_sent',
      ERROR = 'error'
    end

    class HttpEvent < Event
      attr_reader :request_id, :retries, :body
      def initialize(type:, message:, request_id:, body:, retries:)
        super(type: type, message: message)
        @request_id = request_id
        @retries = retries
        @body = body
      end
    end

    class RequestSentEvent < HttpEvent
      attr_reader :timeout
      def initialize(message:, request_id:, body:, retries:, timeout:)
        super(type: EventType::REQUEST_SENT, message: message, request_id: request_id, body: body, retries: retries)
        # The amount of time that will be allowed before this request times out. For languages that have a native time span data type, this should be that type. Otherwise, it should be an integer that represents the number of milliseconds.
        @timeout = timeout
      end
    end

    class ResponseReceivedEvent < HttpEvent
      attr_reader :elapsed
      def initialize(message:, request_id:, body:, retries:, elapsed:)
        super(type: EventType::RESPONSE_RECEIVED, message: message, request_id: request_id, body: body, retries: retries)
        # The amount of time that elapsed between when the request was sent and when the response was received. For languages that have a native time span data type, this should be that type. Otherwise, it should be an integer that represents the number of milliseconds.
        @elapsed = elapsed
      end
    end

    class EventEmitter
      # maybe check that at least _one_ of the following are implemented?
      def on_request_sent(request_sent_event); end

      def on_response_received(response_received_event); end

      def on_error(error_event); end
    end
  end

  class Client
    attr_accessor :configuration

    def initialize(api_key:, retries: nil, timeout: nil, page_size: nil, base_url: nil, subscriber: nil)
      @configuration = Configuration.new(
        api_key: api_key,
        retries: retries,
        base_url: base_url,
        timeout: timeout,
        page_size: page_size,
        subscriber: subscriber
      )
      internal_client = InternalClient.new(@configuration)
      @address = Domain::Address.new(internal_client)
      @package = Domain::Package.new(internal_client)
      @carriers = Domain::Carrier.new(internal_client)
    end

    #
    # Validates an address
    # @param [Address] address
    # @param [<Type>] options
    # @param config [Hash?]
    # @option config [String?] :api_key
    # @option config [String?] :base_url
    # @option config [Number?] :retries
    # @option config [Number?] :timeout
    #
    # @return [::ShipEngine::AddressValidationResult] <description>
    #
    def validate_address(address, config = {})
      @address.validate(address, config)
    end

    #
    # Validates an address
    # @param [Address] address
    # @param config [Hash]
    # @option config [String?] :api_key
    # @option config [String?] :base_url
    # @option config [Number?] :retries
    # @option config [Number?] :timeout
    #
    # @return [::ShipEngine::NormalizedAddress]
    #
    def normalize_address(address, config = {})
      @address.normalize(address, config)
    end

    def list_carrier_accounts(carrier_code: nil, config: {})
      @carriers.list_accounts(carrier_code: carrier_code, config: config)
    end

    def track_package_by_id(package_id, config = {})
      @package.track_by_id(package_id, config)
    end

    def track_package_by_tracking_number(tracking_number, carrier_code, config = {})
      @package.track_by_tracking_number(tracking_number, carrier_code, config)
    end
  end
end
