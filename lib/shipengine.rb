# frozen_string_literal: true

# for client class
require 'shipengine/internal_client'
require 'shipengine/domain'

# just for exporting
require 'shipengine/version'
require 'shipengine/exceptions'
require 'shipengine/utils/validate'
require 'shipengine/constants'

module ShipEngine
  class Configuration
    attr_accessor :api_key, :retries, :base_url, :timeout, :page_size

    def initialize(api_key:, retries: nil, timeout: nil, page_size: nil, base_url: nil)
      @api_key = api_key
      @base_url = base_url || (ENV['USE_SIMENGINE'] == 'true' ? 'https://simengine.herokuapp.com/jsonrpc' : 'https://api.shipengine.com')
      @retries = retries || 1
      @timeout = timeout || 5 # https://github.com/lostisland/faraday/issues/708
      @page_size = page_size || 50
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

  class Client
    attr_accessor :configuration

    def initialize(api_key:, retries: nil, timeout: nil, page_size: nil, base_url: nil)
      @configuration = Configuration.new(api_key: api_key, retries: retries, base_url: base_url, timeout: timeout,
                                         page_size: page_size)

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
