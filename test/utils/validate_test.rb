# frozen_string_literal: true

require "test_helper"

require "shipengine/utils/validate"
require "shipengine/exceptions"

def assert_error_message(error_class, expected_message = nil, &block)
  err = assert_raises(error_class, &block)
  assert_match(/#{expected_message}/, err.message) unless expected_message.nil?
  err
end

validate = ShipEngine::Utils::Validate
exceptions = ShipEngine::Exceptions

describe "Assertion testing" do
  field_name = "my_field"
  it "should validate an array of strings" do
    err = assert_error_message(exceptions::ValidationError, "#{field_name} must be an Array.") do
      validate.array_of_str(field_name, "not_a_string_array")
    end
    assert_equal ::ShipEngine::Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE), err.code
  end

  it "should throw exception if not hash" do
    validate.hash(field_name, { name: "hash" })
    assert_error_message(exceptions::ValidationError, "must be Hash.") do
      validate.hash(field_name, "foo")
    end
  end

  it "should throw error if hash is nil" do
    err = assert_error_message(exceptions::ValidationError) do
      validate.hash(field_name, nil)
    end
    assert_equal ::ShipEngine::Exceptions::ErrorCode.get(:FIELD_VALUE_REQUIRED), err.code
  end

  it "should validate a non-whitespace-string" do
    validate.non_whitespace_str(field_name, "hello")
    validate.non_whitespace_str(field_name, " hello ")
    err = assert_error_message(exceptions::ValidationError, "cannot be all whitespace.") do
      validate.non_whitespace_str(field_name, "  ")
      validate.non_whitespace_str(field_name, "")
    end
    assert_equal ::ShipEngine::Exceptions::ErrorCode.get(:INVALID_FIELD_VALUE), err.code
  end
end
