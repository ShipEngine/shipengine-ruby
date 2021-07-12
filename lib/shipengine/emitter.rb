# frozen_string_literal: true
module ShipEngine
  module Emitter
    class Event
      require "date"
      require "uri"
      attr_reader :datetime, :type, :message
      def initialize(type:, message:)
        @type = type
        @message = message
        @datetime = Time.now
      end
    end

    class EventType
      RESPONSE_RECEIVED = "response_received"
      REQUEST_SENT = "request_sent"
      ERROR = "error"
    end

    class ErrorEvent < Event
      attr_reader :request_id, :error_source, :error_code, :error_type
      def initialize(message:, request_id: nil, error_source: nil, error_code: nil, error_type:)
        super(type: EventType::ERROR, message: message)
        @request_id = request_id
        @error_source = error_source
        @error_code = error_code
        @error_type = error_type
      end
    end

    class HttpEvent < Event
      attr_reader :request_id, :retry_attempt, :body, :headers, :url
      def initialize(type:, message:, request_id:, body:, retry_attempt:, headers:, url:)
        super(type: type, message: message)
        url = URI(url)
        @url = url
        @headers = headers
        @request_id = request_id
        @retry_attempt = retry_attempt
        @body = body
      end
    end

    class RequestSentEvent < HttpEvent
      attr_reader :timeout
      def initialize(message:, request_id:, body:, retry_attempt:, headers:, url:, timeout:)
        super(
          type: EventType::REQUEST_SENT,
          message: message,
          request_id: request_id,
          body: body,
          headers: headers,
          url: url,
          retry_attempt: retry_attempt
        )
        # The amount of time that will be allowed before this request times out. For languages that have a native time span data type, this should be that type. Otherwise, it should be an integer that represents the number of milliseconds.
        @timeout = timeout
      end
    end

    class ResponseReceivedEvent < HttpEvent
      attr_reader :elapsed, :status_code
      def initialize(message:, request_id:, body:, retry_attempt:, headers:, url:, elapsed:, status_code:)
        super(
          type: EventType::RESPONSE_RECEIVED,
          message: message,
          request_id: request_id,
          body: body,
          headers: headers,
          url: url,
          retry_attempt: retry_attempt
        )
        # The amount of time that elapsed between when the request was sent and when the response was received. For languages that have a native time span data type, this should be that type. Otherwise, it should be an integer that represents the number of milliseconds.
        @elapsed = elapsed
        @status_code = status_code
      end
    end

    # @abstract Subclass and override {#on_request_sent} / {#on_response_received} / {#on_error} # to implement a custom EventEmitter
    class EventEmitter
      #
      # Implement this method to subscribe to `on_request_sent` events.
      #
      # @param request_sent_event [::ShipEngine::Emitter::RequestSentEvent]
      def on_request_sent(request_sent_event); end

      #
      # Implement this method to subscribe to `on_response_received` events.
      #
      # @param request_sent_event [::ShipEngine::Emitter::ResponseReceivedEvent]
      def on_response_received(response_received_event); end

      #
      # Implement this method to subscribe to `error` events.

      # @param request_sent_event [::ShipEngine::Emitter::ErrorEvent]
      def on_error(error_event); end
    end
  end
end
