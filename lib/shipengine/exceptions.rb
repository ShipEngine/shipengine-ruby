require 'shipengine/exceptions/error_code'

module ShipEngine
  module Exceptions
    class ShipEngineError < StandardError
      def initialize(message_or_messages)
        message = message_or_messages.is_a?(Array) ? message_or_messages.join('\n') : message_or_messages
        super(message)
      end
    end

    # 400 error, or other "user exceptions"
    class ShipEngineErrorDetailed < ShipEngineError
      attr_reader :request_id, :message, :source, :type, :code

      def initialize(request_id, message, source, type, code)
        super(message)
        @request_id = request_id
        @message = message
        @source = source
        @type = type
        @code = code
      end
    end

    # 400 error, or other "user exceptions"
    class InvalidParams < ShipEngineErrorDetailed
      def initialize(message)
        super(nil, message, 'shipengine', 'validation', ErrorCode.get(:INVALID_FIELD_VALUE))
      end
    end


    class FieldValueRequired < ShipEngineErrorDetailed
      def self.assert_field_exists(field_name, value)
        raise self.new(field_name) if value.nil? || value == ''
      end
      def initialize(missing_item)
        super(nil, "#{missing_item} must specified.", 'shipengine', 'validation', ErrorCode.get(:FIELD_VALUE_REQUIRED))
      end
    end
  end
end
