# frozen_string_literal: true

require_relative 'exceptions/error_code'
require_relative 'exceptions/error_type'

module ShipEngine
  module Exceptions
    # 400 error, or other "user exceptions"
    class ShipEngineError < StandardError
      # message is inherited
      attr_reader :request_id, :source, :type, :code

      def initialize(message:, source:, type:, code:, request_id:)
        code = Exceptions::ErrorCode.get_by_str(code) if code.is_a?(String)
        super(message)
        @request_id = request_id
        @source = source || 'shipengine'
        @type = type
        @code = code
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
      def initialize(message:, code:, request_id: nil, source: nil)
        super(message: message, source: source, type: Exceptions::ErrorType.get(:SYSTEM), code: code, request_id: request_id)
      end
    end

    class RateLimitError < SystemError
      attr_reader :retry_attempt
      def initialize(message:, request_id: nil, retry_attempt: nil)
        super(message: message, code: 'rate_limit_error', request_id: request_id)
        @retry_attempt = retry_attempt
      end
    end

    def self.create_error_instance_by_type(type:, message:, code:, request_id: nil, source: nil)
      error = get_error_class_by_type(type)
      return error.new(message: message, code: code, request_id: request_id, source: source) unless error.nil?

      ShipEngineError.new(message: message, source: source, code: code, type: type, request_id: request_id)
    end

    # @param error_type [String] e.g "validation"
    # @return [BusinessRulesError, AccountStatusError, SecurityError, SystemError, ValidationError]
    def self.get_error_class_by_type(error_type)
      case error_type
      when Exceptions::ErrorType.get(:BUSINESS_RULES)
        BusinessRulesError
      when Exceptions::ErrorType.get(:VALIDATION)
        ValidationError
      when Exceptions::ErrorType.get(:ACCOUNT_STATUS)
        AccountStatusError
      when Exceptions::ErrorType.get(:SECURITY)
        SecurityError
      when Exceptions::ErrorType.get(:SYSTEM)
        SystemError
      end
    end
  end
end
