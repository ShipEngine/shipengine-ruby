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
    attr_accessor :api_key, :retries, :base_url, :timeout

    def initialize(api_key: nil, base_url: nil, retries: nil, timeout: nil)
      @api_key = api_key
      @base_url = base_url || 'https://simengine.herokuapp.com/jsonrpc'
      @retries = retries || 0
      @timeout = timeout || 60 # https://github.com/lostisland/faraday/issues/708
      validate
    end

    def merge(api_key: nil, base_url: nil, retries: nil, timeout: nil)
      copy = clone
      copy.api_key = api_key if api_key
      copy.base_url = base_url if base_url
      copy.retries =  retries if retries
      copy.timeout =  timeout if retries
      copy.validate
      copy
    end

    # since the fields in the class are mutable, we should be able to validate them at any time.
    def validate
      Utils::Validate.str('A ShipEngine API key', @api_key)
      Utils::Validate.str('Base URL', @base_url)
      Utils::Validate.non_neg_int('Retries', @retries)
      Utils::Validate.positive_int('Timeout', @timeout)
    end
  end

  class Client
    attr_accessor :configuration

    def initialize(api_key:)
      @configuration = Configuration.new(api_key: api_key)

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
