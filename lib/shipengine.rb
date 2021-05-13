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

    def initialize(api_key:, retries: nil, timeout: nil, base_url: nil, page_size: nil)
      @api_key = api_key
      @base_url = base_url || ENV['USE_SIMENGINE'] == 'true' ? 'https://simengine.herokuapp.com/jsonrpc' : 'https://api.shipengine.com'
      @retries = retries || 0
      @timeout = timeout || 5 # https://github.com/lostisland/faraday/issues/708
      @page_size = page_size || 50
      validate
    end

    # @param [Hash] cfg
    def merge(cfg)
      copy = clone
      copy.api_key = cfg[:api_key] if cfg.key?(:api_key)
      copy.base_url = cfg[:base_url] if cfg.key?(:base_url)
      copy.retries =  cfg[:retries] if cfg.key?(:retries)
      copy.timeout =  cfg[:timeout] if cfg.key?(:timeout)
      copy.page_size = cfg[:page_size] if cfg.key?(:page_size)
      copy.validate
      copy
    end

    def validate_fields(cfg)
      Utils::Validate.str('A ShipEngine API key', cfg[:api_key]) if cfg.key?(:api_key)
      Utils::Validate.str('Base URL', cfg[:base_url]) if cfg.key?(:base_url)
      Utils::Validate.non_neg_int('Retries', cfg[:retries]) if cfg.key?(:retries)
      Utils::Validate.positive_int('Timeout', cfg[:timeout]) if cfg.key?(:timeout)
    end

    # since the fields in the class are mutable, we should be able to validate them at any time.
    def validate
      validate_fields({ api_key: @api_key, base_url: @base_url, retries: @retries, timeout: @timeout })
    end
  end

  class Client
    attr_accessor :configuration

    def initialize(api_key:, retries: nil, timeout: nil, base_url: nil, page_size: nil)
      @configuration = Configuration.new(api_key: api_key, retries: retries, base_url: base_url, timeout: timeout,
                                         page_size: page_size)

      internal_client = InternalClient.new(@configuration)
      @address = Domain::Address.new(internal_client)
      @package = Domain::Package.new(internal_client)
    end

    #
    # Validates an address
    # @param [Address] address
    # @param [<Type>] options
    # @option options [<Type>] :<key> <description>
    # @option options [<Type>] :<key> <description>
    # @option options [<Type>] :<key> <description>
    #
    # @return [::ShipEngine::AddressValidationResult] <description>
    #
    def validate_address(address, options = {})
      @address.validate(address, options)
    end

    def track_package_by_id(package_id, opts = {})
      @package.track_by_id(package_id, opts)
    end

    def track_package_by_tracking_number(tracking_number, carrier_code, opts = {})
      @package.track_by_tracking_number(tracking_number, carrier_code, opts)
    end
  end
end
