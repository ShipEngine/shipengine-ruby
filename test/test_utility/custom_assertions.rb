# frozen_string_literal: true

require 'minitest/assertions'

module CustomAssertions
  include Minitest::Assertions
  def assert_response_error(err_hash, response)
    assert_equal(err_hash[:code], response.code) if err_hash.key?(:code)
    assert_equal(err_hash[:source], response.source) if err_hash.key?(:source)
    assert_equal(err_hash[:message], response.message) if err_hash.key?(:message)
    assert_equal(err_hash[:type], response.type) if err_hash.key?(:type)
  end

  def assert_raises_shipengine(error_class, err_hash, &block)
    err = assert_raises error_class, &block
    assert_response_error(err_hash, err)
  end

  def assert_raises_shipengine_validation(err_hash, &block)
    expected = {
      code: err_hash.fetch(:code),
      message: err_hash.fetch(:message),
      source: 'shipengine',
      type: 'validation'
    }.merge(err_hash)

    assert_raises_shipengine(ShipEngine::Exceptions::ValidationError, expected, &block)
  end
end
