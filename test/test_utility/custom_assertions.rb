# frozen_string_literal: true

require 'minitest/assertions'

module CustomAssertions
  include Minitest::Assertions
  def assert_response_error(response, err_hash)
    assert_equal(err_hash[:code], response.code) if err_hash.key?(:code)
    assert_equal(err_hash[:source], response.source) if err_hash.key?(:source)
    assert_equal(err_hash[:message], response.message) if err_hash.key?(:message)
    assert_equal(err_hash[:type], response.type) if err_hash.key?(:type)
  end
end
