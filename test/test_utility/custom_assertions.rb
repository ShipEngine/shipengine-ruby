# frozen_string_literal: true

require "minitest/assertions"

module CustomAssertions
  include Minitest::Assertions

  def assert_within_secs_from_now(secs, time)
    diff = Time.now - time
    assert_operator(diff, :<, secs, "should be #{secs} from now. Got diff: #{diff}")
  end

  def assert_content_type_json(headers)
    assert_match(%r{application/json}i, fuzzy_get_header("Content-Type", headers), "should have content-type application/json. headers #{headers}")
  end

  def assert_between(greater_than_this_value, less_than_this_value, value, field = "value")
    assert(value > greater_than_this_value && value < less_than_this_value,
      "#{field} should be between #{greater_than_this_value} and #{less_than_this_value}. Got #{value}")
  end

  def assert_equal_value(key, value1, value2)
    assert_equal(value1, value2, "-> #{key}")
  end

  def assert_equal_fields(some_hash, some_class)
    some_hash.keys.each do |symbol|
      assert_equal(some_hash[symbol], some_class.send(symbol), "-> #{symbol}") if expected_event.key?(symbol)
    end
  end

  # @param expected [Hash]
  # @param response [::ShipEngine::TrackPackageResult]
  def assert_track_package_result(expected, actual)
    raise "no package" unless actual.package

    assert_equal_value("package_id", expected[:package_id], actual.package.package_id) if expected[:package_id]
    # assert_equal(expected_carrier[:name], actual.carrier.name, "~> carrier.name")
  end

  # @param expected_event [Hash]
  # @param response_event [::ShipEngine::Emitter::ErrorEvent]
  def assert_error_event(expected_event, actual_event)
    assert(actual_event, "ErrorEvent should exist.")
    assert_kind_of(::ShipEngine::Emitter::ErrorEvent, actual_event)
    assert_equal(expected_event[:error_code], actual_event.error_code) if expected_event.key?(:error_code)
    assert_equal(expected_event[:message], actual_event.message) if expected_event.key?(:message)
    assert_equal(expected_event[:error_type], actual_event.error_type) if expected_event.key?(:error_type)
    assert_equal(expected_event[:error_source], actual_event.error_source) if expected_event.key?(:error_source)
    # assert_equal_field(expected_event, actual_event, [:retries, :datetime, :message, :type, :timeout, :request_id])
    assert_kind_of(Time, actual_event.datetime, "datetime should be a time")
    assert_equal(expected_event[:datetime], actual_event.datetime) if expected_event.key?(:datetime)
    assert_equal(expected_event[:timeout], actual_event.timeout) if expected_event.key?(:timeout)
  end

  def assert_jsonrpc_method_in_body(method, body)
    assert_equal(body["method"], method)
  end

  # @param expected_event [Hash]
  # @param response_event [::ShipEngine::Emitter::RequestSentEvent]
  def assert_request_sent_event(expected_event, request_sent_event)
    assert_kind_of(::ShipEngine::Emitter::RequestSentEvent, request_sent_event)
    assert_equal(::ShipEngine::Emitter::EventType::REQUEST_SENT, request_sent_event.type)
    assert_request_id_equal(:__REGEX_MATCH__, request_sent_event.request_id)
    # assert_equal_field(expected_event, request_sent_event, [:retries, :datetime, :message, :type, :timeout, :request_id])
    assert_equal(expected_event[:retry_attempt], request_sent_event.retry_attempt) if expected_event.key?(:retry_attempt)
    assert_kind_of(Time, request_sent_event.datetime, "datetime should be a time")
    assert_equal(expected_event[:datetime], request_sent_event.datetime) if expected_event.key?(:datetime)
    assert_equal(expected_event[:message], request_sent_event.message) if expected_event.key?(:message)
    assert_equal(expected_event[:timeout], request_sent_event.timeout) if expected_event.key?(:timeout)
  end

  # @param expected_event [Hash]
  # @param response_event [::ShipEngine::Emitter::ResponseReceivedEvent]
  def assert_response_received_event(expected_event, response_event)
    assert_kind_of(::ShipEngine::Emitter::ResponseReceivedEvent, response_event)
    assert_equal(::ShipEngine::Emitter::EventType::RESPONSE_RECEIVED, response_event.type)
    assert_request_id_equal(:__REGEX_MATCH__, response_event.request_id)
    assert_equal(expected_event[:status_code], response_event.status_code) if expected_event.key?(:status_code)
    if expected_event.key?(:headers)
      expected_headers = expected_event[:headers]
      response_headers = response_event.headers
      assert_equal(expected_headers["Content-Type"], response_headers["Content-Type"])
    end
    assert_jsonrpc_method_in_body(expected_event[:method], response_event.body) if expected_event.key?(:method)
    assert_equal(expected_event[:retry_attempt], response_event.retry_attempt) if expected_event.key?(:retry_attempt)
    assert_kind_of(Time, response_event.datetime, "datetime should be a time")
    assert_equal(expected_event[:datetime], response_event.datetime) if expected_event.key?(:datetime)
    assert_equal(expected_event[:message], response_event.message) if expected_event.key?(:message)
    assert_equal(expected_event[:type], response_event.type) if expected_event.key?(:type)
    assert_equal(expected_event[:elapsed], response_event.elapsed) if expected_event.key?(:elapsed)
    assert_request_id_equal(expected_event[:request_id], response_event.request_id) if expected_event.key?(:request_id)
    assert_equal(expected_event[:url], response_event.url) if expected_event.key?(:url)
  end

  def assert_response_error(expected_err, response_err)
    if expected_err.key?(:message)
      assert_equal(expected_err[:message],
        response_err.to_s) && assert_equal(expected_err[:message], response_err.message)
    end
    assert_equal(expected_err[:code], response_err.code) if expected_err.key?(:code)
    assert_equal(expected_err[:source], response_err.source) if expected_err.key?(:source)
    assert_equal(expected_err[:type], response_err.type) if expected_err.key?(:type)
    assert_equal(expected_err[:url], response_err.url) if expected_err.key?(:url)
    assert_request_id_equal(expected_err[:request_id], response_err.request_id) if expected_err.key?(:request_id)
  end

  def assert_request_id_format(id)
    assert_match(/^req_\w+$/, id, "request_id invalid.")
  end

  def assert_request_id_equal(expected_id, response_id)
    if expected_id.nil?
      assert_nil(response_id)
    elsif expected_id == :__REGEX_MATCH__
      assert_request_id_format(response_id)
    else
      assert_equal(expected_id, value)
    end
  end

  def assert_raises_shipengine(error_class, expected_err, &block)
    err = assert_raises(error_class, &block)
    assert_response_error(expected_err, err)
    err
  end

  def assert_raises_shipengine_validation(expected_err, &block)
    copy_expected_err = expected_err.clone
    copy_expected_err[:source] = "shipengine"
    copy_expected_err[:type] = "validation"
    assert_raises_shipengine(ShipEngine::Exceptions::ValidationError, copy_expected_err, &block)
  end

  def assert_raises_shipengine_timeout(expected_err, &block)
    copy_expected_err = expected_err.clone
    copy_expected_err[:source] = "shipengine"
    copy_expected_err[:type] = "system"
    copy_expected_err[:url] = URI("https://www.shipengine.com/docs/rate-limits")
    copy_expected_err[:request_id] = :__REGEX_MATCH__
    assert_raises_shipengine(ShipEngine::Exceptions::TimeoutError, copy_expected_err, &block)
  end

  def assert_validated_address(expected_address, response_address)
    raise "address_line1 is a required key." unless expected_address[:address_line1]

    assert_equal(expected_address[:address_line1], response_address.address_line1, "-> address_line1") if expected_address.key?(:address_line1)
    assert_equal(expected_address[:address_line2], response_address.address_line2, "-> address_line2") if expected_address.key?(:address_line2)
    assert_equal(expected_address[:address_line3], response_address.address_line3, "-> address_line3") if expected_address.key?(:address_line3)
    assert_equal(expected_address[:name], response_address.name, "-> name") if expected_address.key?(:name)
    assert_equal(expected_address[:company_name], response_address.company_name, "-> company_name") if expected_address.key?(:company_name)
    assert_equal(expected_address[:phone], response_address.phone, "-> phone") if expected_address.key?(:phone)
    assert_equal(expected_address[:city_locality], response_address.city_locality, "-> city_locality") if expected_address.key?(:city_locality)
    assert_equal(expected_address[:state_province], response_address.state_province, "-> state_province") if expected_address.key?(:state_province)
    assert_equal(expected_address[:postal_code], response_address.postal_code, "-> postal_code") if expected_address.key?(:postal_code)
    assert_equal(expected_address[:country_code], response_address.country_code, "-> country_code") if expected_address.key?(:country_code)
    assert_equal(expected_address[:address_residential_indicator], response_address.address_residential_indicator,
      "-> address_residential_indicator") if expected_address.key?(:address_residential_indicator)
  end

  # @param response [::ShipEngine::AddressValidationResult]
  # @param expected_address [Hash]
  def assert_address_validation_result(expected_result, response_result)
    assert_equal(expected_result[:status], response_result.status) if expected_result.key?(:status)
    assert_messages_equals(expected_result[:messages], response_result.messages) if expected_result.key?(:messages)

    return assert_nil(response_result.matched_address, "~> matched_address") if expected_result.key?(:matched_address) && expected_result[:matched_address].nil?

    expected_address_original = expected_result[:original_address]
    expected_address_matched = expected_result[:matched_address]
    assert_validated_address(expected_address_original, response_result.original_address)
    assert_validated_address(expected_address_matched, response_result.matched_address)
  end

  def assert_raises_rate_limit_error(retries: nil, &block)
    err = assert_raises_shipengine(ShipEngine::Exceptions::RateLimitError, {
      code: "rate_limit_exceeded",
      message: "You have exceeded the rate limit.",
      source: "shipengine",
    }, &block)
    assert_equal(retries, err.retries, "Retries should be the same") unless retries.nil?
  end

  # @param expected_messages [Array<Hash>]
  # @param response_messages [Array<::ShipEngine::AddressValidationMessage>]
  def assert_messages_equals(expected_messages, response_messages)
    assert_equal(expected_messages.length, response_messages.length,
      "expected_messages and response_messages should be the same length. expected: #{expected_messages}, response: #{response_messages}")
    expected_messages.each_with_index do |message, idx|
      r_msg = response_messages[idx]
      assert_equal(message.fetch(:code), r_msg.code)
      assert_equal(message.fetch(:type), r_msg.type)
      assert_equal(message.fetch(:message), r_msg.message)
    end
  end

  # @param number [Int] - number of times spy method should be called
  # @param spy [Spy] - spy from "Spy" library
  def assert_called(number, spy)
    assert_equal(number, spy.calls.count, "Should be called #{number} times.")
  end

  def assert_tracking_events_in_order(events)
    previous_date_time = events[0].datetime
    events.each do |event|
      status = event.status
      assert(
        event.datetime >= previous_date_time,
        "Event #{status} has an earlier timestamp that #{previous_date_time}"
      )
      previous_date_time = event.datetime
    end
  end

  def assert_delivery_date_match(result)
    assert_equal(
      result.shipment.actual_delivery_date,
      result.events[-1].datetime,
      "The actual_delivery_datetime"
    )
  end

  def assert_valid_iso_string(iso_string)
    if !iso_string[::ShipEngine::Constants::VALID_ISO_STRING].nil?
      true
    else
      false
    end
  end

  def assert_valid_iso_string_with_no_tz(iso_string)
    if !iso_string[::ShipEngine::Constants::VALID_ISO_STRING_WITH_NO_TZ].nil?
      true
    else
      false
    end
  end
end
