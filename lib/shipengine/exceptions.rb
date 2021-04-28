module ShipEngine
  module Exceptions
    #  standard class - network connection error / internal server error /etc
    class ShipEngineError < StandardError
      def initialize(message_or_messages)
        message = message_or_messages.is_a?(Array) ? message_or_messages.join('\n') : message_or_messages
        super(message)
      end
    end

    # 400 error, or other "user exceptions"
    class ValidationError < ShipEngineError
    end
  end
end
