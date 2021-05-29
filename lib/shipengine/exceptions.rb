# frozen_string_literal: true

require_relative "exceptions/error_code"
require_relative "exceptions/error_type"

module ShipEngine
  module Exceptions
    DEFAULT_SOURCE = "shipengine"
    # 400 error, or other "user exceptions"
    class ShipEngineError < StandardError
      # message is inherited
      attr_reader :request_id, :source, :type, :code, :url

      def initialize(message:, source:, type:, code:, request_id:, url: nil)
        code = Exceptions::ErrorCode.get_by_str(code) if code.is_a?(String)
        super(message)
        @request_id = request_id
        @source = source || DEFAULT_SOURCE
        @type = type
        @code = code
        @url = url
      end
    end

    # 400 error, or other "user exceptions"
    class ValidationError < ShipEngineError
      def initialize(message:, code:, request_id: nil, source: nil)
        super(message: message, source: source, type: Exceptions::ErrorType.get(:VALIDATION), code: code, request_id: request_id)
      end
    end

    # only create custom errors for error "types" (which encompass codes). Prefer to use generic ShipEngine errors.
    def self.create_invalid_field_value_error(message, request_id = nil, source = nil)
      ValidationError.new(message: message, code: Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE), request_id: request_id, source: source)
    end

    def self.create_required_error(field_name, request_id = nil, source = nil)
      ValidationError.new(message: "#{field_name} must be specified.",
        code: Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED), request_id: request_id, source: source)
    end

    def self.create_invariant_error(message, request_id = nil)
      SystemError.new(message: "INVARIANT ERROR: #{message}", code: Exceptions::ErrorCode.get(:UNSPECIFIED),
        request_id: request_id)
    end

    class BusinessRulesError < ShipEngineError
      def initialize(message:, code:, request_id: nil, source: nil)
        super(message: message, source: source, type: Exceptions::ErrorType.get(:BUSINESS_RULES), code: code, request_id: request_id)
      end
    end

    class AccountStatusError < ShipEngineError
      def initialize(message:, code:, request_id: nil, source: nil)
        super(message: message, source: source, type: Exceptions::ErrorType.get(:ACCOUNT_STATUS), code: code, request_id: request_id)
      end
    end

    class SecurityError < ShipEngineError
      def initialize(message:, code:, request_id: nil, source: nil)
        super(message: message, source: source, type: Exceptions::ErrorType.get(:SECURITY), code: code, request_id: request_id)
      end
    end

    class SystemError < ShipEngineError
      def initialize(message:, code:, request_id: nil, source: nil, url: nil)
        super(message: message, source: source, type: Exceptions::ErrorType.get(:SYSTEM), code: code, request_id: request_id, url: url)
      end
    end

    class TimeoutError < SystemError
      def initialize(message:, source: nil, request_id: nil)
        super(message: message, url: URI("https://www.shipengine.com/docs/rate-limits"), code: ErrorCode.get(:TIMEOUT), request_id: request_id, source: source || DEFAULT_SOURCE)
      end
    end

    class RateLimitError < SystemError
      attr_reader :retries

      def initialize(retries: nil, message: "You have exceeded the rate limit.", source: nil, request_id: nil)
        super(
          message: message,
          code: ErrorCode.get(:RATE_LIMIT_EXCEEDED),
          request_id: request_id,
          source: source,
          url: URI("https://www.shipengine.com/docs/rate-limits"),
        )
        @retries = retries
      end
    end

    def self.create_error_instance(type:, message:, code:, request_id: nil, source: nil, config: nil)
      case type
      when Exceptions::ErrorType.get(:BUSINESS_RULES)
        BusinessRulesError.new(message: message, code: code, request_id: request_id, source: source)
      when Exceptions::ErrorType.get(:VALIDATION)
        ValidationError.new(message: message, code: code, request_id: request_id, source: source)
      when Exceptions::ErrorType.get(:ACCOUNT_STATUS)
        AccountStatusError.new(message: message, code: code, request_id: request_id, source: source)
      when Exceptions::ErrorType.get(:SECURITY)
        SecurityError.new(message: message, code: code, request_id: request_id, source: source)
      when Exceptions::ErrorType.get(:SYSTEM)
        case code
        when ErrorCode.get(:RATE_LIMIT_EXCEEDED)
          RateLimitError.new(message: message, request_id: request_id, source: source, retries: config.retries)
        when ErrorCode.get(:TIMEOUT)
          TimeoutError.new(message: message, request_id: request_id, source: source)
        else
          SystemError.new(message: message, code: code, request_id: request_id, source: source)
        end
      else
        ShipEngineError.new(message: message, code: code, request_id: request_id, source: source)
      end
    end

    # @param error_type [String] e.g "validation"
    # @return [BusinessRulesError, AccountStatusError, SecurityError, SystemError, ValidationError]
  end
end
