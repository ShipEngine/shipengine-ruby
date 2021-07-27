# frozen_string_literal: true
module ShipEngine
  class Configuration
    attr_accessor :api_key, :retries, :base_url, :timeout, :page_size

    def initialize(api_key:, retries: nil, timeout: nil, page_size: nil, base_url: nil)
      @api_key = api_key
      @base_url = base_url || Constants.base_url
      @retries = retries || 1
      @timeout = timeout || 30_000
      @page_size = page_size || 50
      validate
    end

    # @param opts [Hash] the options to create a message with.
    # @option opts [String] :ap The subject
    # @option opts [String] :from ('nobody') From address
    # @option opts [String] :to Recipient email
    # @option opts [String] :body ('') The email's bod
    def merge(config)
      copy = clone
      copy.api_key   = config[:api_key] if config.key?(:api_key)
      copy.base_url  = config[:base_url] if config.key?(:base_url)
      copy.retries   =  config[:retries] if config.key?(:retries)
      copy.timeout   =  config[:timeout] if config.key?(:timeout)
      copy.page_size = config[:page_size] if config.key?(:page_size)
      copy.validate
      copy
    end

    # since the fields in the class are mutable, we should be able to validate them at any time.
    protected

    def validate
      Utils::Validate.str("A ShipEngine API key", @api_key)
      Utils::Validate.str("Base URL", @base_url)
      Utils::Validate.non_neg_int("Retries", @retries)
      Utils::Validate.positive_int("Timeout", @timeout)
      Utils::Validate.positive_int("Page size", @page_size)
    end
  end
end
