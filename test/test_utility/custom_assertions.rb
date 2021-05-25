# frozen_string_literal: true

require 'minitest/assertions'

module CustomAssertions
  include Minitest::Assertions
  def assert_response_error(expected_err, response_err)
    assert_equal(expected_err[:message], response_err.to_s) if expected_err.key?(:message)
    assert_equal(expected_err[:message], response_err.message) if expected_err.key?(:message)
    assert_equal(expected_err[:code], response_err.code) if expected_err.key?(:code)
    assert_equal(expected_err[:source], response_err.source) if expected_err.key?(:source)
    assert_equal(expected_err[:type], response_err.type) if expected_err.key?(:type)
    assert_request_id_equal(expected_err[:request_id], response_err.request_id) if expected_err.key?(:request_id)
  end

  def assert_request_id_format(id)
    assert_match(/^req_\w+$/, id, 'request_id invalid.')
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
    err = assert_raises error_class, &block
    assert_response_error(expected_err, err)
  end

  def assert_raises_shipengine_validation(expected_err, &block)
    copy_expected_err = expected_err.clone
    copy_expected_err[:source] = 'shipengine'
    copy_expected_err[:type] = 'validation'
    assert_raises_shipengine(ShipEngine::Exceptions::ValidationError, copy_expected_err, &block)
  end

  def assert_normalized_address(expected_address, response_address)
    # rubocop:disable Layout/LineLength
    raise 'Street is a required key.' unless expected_address[:street]

    assert_equal(expected_address[:residential], response_address.residential?, '-> residential') if expected_address.key?(:residential)
    assert_equal(expected_address[:name], response_address.name, '-> name') if expected_address.key?(:name)
    assert_equal(expected_address[:company], response_address.company, '-> company') if expected_address.key?(:company)
    assert_equal(expected_address[:phone], response_address.phone, '-> phone') if expected_address.key?(:phone)
    assert_equal(expected_address[:street], response_address.street, '-> street')
    assert_equal(expected_address[:city_locality], response_address.city_locality, '-> city_locality') if expected_address.key?(:city_locality)
    assert_equal(expected_address[:country], response_address.country, '-> country') if expected_address.key?(:country)
    # rubocop:enable Layout/LineLength
  end

  # @param response [::ShipEngine::AddressValidationResult]
  # @param expected_address [Hash]
  def assert_address_validation_result(expected_result, response_result)
    # rubocop:disable Layout/LineLength
    assert_equal(expected_result[:valid], response_result.valid?, '-> valid') if expected_result.key?(:valid)
    assert_messages_equals(expected_result[:warnings], response_result.warnings) if expected_result.key?(:warnings)
    assert_messages_equals(expected_result[:info], response_result.info) if expected_result.key?(:info)
    assert_messages_equals(expected_result[:errors], response_result.errors) if expected_result.key?(:errors)

    return assert_nil(response_result.normalized_address, '~> normalized_address') if expected_result.key?(:normalized_address) && expected_result[:normalized_address].nil?

    expected_address_normalized = expected_result[:normalized_address]
    assert_normalized_address(expected_address_normalized, response_result.normalized_address)
    # rubocop:enable Layout/LineLength
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
end
