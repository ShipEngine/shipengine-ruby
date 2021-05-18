# frozen_string_literal: true

require_relative 'exceptions/error_code'
require_relative 'exceptions/error_type'

module ShipEngine
  module Exceptions
    # 400 error, or other "user exceptions"
    class ShipEngineError < StandardError
      attr_reader :request_id, :message, :source, :type, :code

      def initialize(message:, source:, type:, code:, request_id:)
        code = Exceptions::ErrorCode.get_by_str(code) if code.is_a?(String)

        super(message)
        @request_id = request_id
        @message = message
        @source = source
        @type = type
        @code = code
      end
    end

    # 400 error, or other "user exceptions"
    class ValidationError < ShipEngineError
      def initialize(message:, code:, request_id: nil)
        super(message: message, source: 'shipengine', type: 'validation', code: code, request_id: request_id)
      end
    end

    # only create custom errors for error "types" (which encompass codes). Prefer to use generic ShipEngine errors.
    def self.create_invalid_field_value_error(message, request_id = nil)
      ValidationError.new(message: message, code: Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE), request_id: request_id)
    end

    def self.create_required_error(missing_item, request_id = nil)
      ValidationError.new(message: "#{missing_item} must be specified.",
                          code: Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED), request_id: request_id)
    end

    def self.create_invariant_error(message, request_id = nil)
      ShipEngineError.new(message: "INVARIANT ERROR: #{message}", source: 'shipengine', type: nil, code: Exceptions::ErrorCode.get(:UNSPECIFIED),
                          request_id: request_id)
    end
  end
end
