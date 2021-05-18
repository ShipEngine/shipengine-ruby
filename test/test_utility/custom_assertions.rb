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
end
