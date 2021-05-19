# frozen_string_literal: true

require 'minitest/assertions'

module CustomAssertions
  include Minitest::Assertions
  def assert_response_error(err_hash, response)
    assert_equal(err_hash[:message], response.message) if err_hash.key?(:message)
    assert_equal(err_hash[:code], response.code) if err_hash.key?(:code)
    assert_equal(err_hash[:source], response.source) if err_hash.key?(:source)
    assert_equal(err_hash[:type], response.type) if err_hash.key?(:type)
    assert_request_id_equal(err_hash[:request_id], response.request_id) if err_hash.key?(:request_id)
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

  def assert_raises_shipengine(error_class, err_hash, &block)
    err = assert_raises error_class, &block
    assert_response_error(err_hash, err)
  end

  def assert_raises_shipengine_validation(err_hash, &block)
    copy_err_hash = err_hash.clone
    copy_err_hash[:source] = 'shipengine'
    copy_err_hash[:type] = 'validation'
    assert_raises_shipengine(ShipEngine::Exceptions::ValidationError, copy_err_hash, &block)
  end

  def assert_normalized_address(expected_address_normalized, response_normalized_address)
    # rubocop:disable Layout/LineLength
    raise 'Street is a required key.' unless expected_address_normalized[:street]

    assert_equal(expected_address_normalized[:residential], response_normalized_address.residential?, '-> residential') if expected_address_normalized.key?(:residential)
    assert_equal(expected_address_normalized[:name], response_normalized_address.name, '-> name') if expected_address_normalized.key?(:name)
    assert_equal(expected_address_normalized[:company], response_normalized_address.company, '-> company') if expected_address_normalized.key?(:company)
    assert_equal(expected_address_normalized[:phone], response_normalized_address.phone, '-> phone') if expected_address_normalized.key?(:phone)
    assert_equal(expected_address_normalized[:street], response_normalized_address.street, '-> street')
    assert_equal(expected_address_normalized[:city_locality], response_normalized_address.city_locality, '-> city_locality') if expected_address_normalized.key?(:city_locality)
    assert_equal(expected_address_normalized[:country], response_normalized_address.country, '-> country') if expected_address_normalized.key?(:country)
    # rubocop:enable Layout/LineLength
  end

  # @param response [::ShipEngine::AddressValidationResult]
  # @param expected_address [Hash]
  def assert_address_validation_result(expected_address, response)
    # rubocop:disable Layout/LineLength
    assert_equal(expected_address[:valid], response.valid?, '-> valid') if expected_address.key?(:valid)
    assert_messages_equals(expected_address[:warnings], response.warnings) if expected_address.key?(:warnings)
    assert_messages_equals(expected_address[:info], response.info) if expected_address.key?(:info)
    assert_messages_equals(expected_address[:errors], response.errors) if expected_address.key?(:errors)

    return assert_nil(response.normalized_address, '~> normalized_address') if expected_address.key?(:normalized_address) && expected_address[:normalized_address].nil?

    expected_address_normalized = expected_address[:normalized_address]
    assert_normalized_address(expected_address_normalized, response.normalized_address)
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
