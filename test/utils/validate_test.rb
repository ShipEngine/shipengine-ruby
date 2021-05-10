# frozen_string_literal: true

require 'test_helper'

require 'shipengine/utils/validate'
require 'shipengine/exceptions'


def assert_error_message(error_class, expected_message = nil, &block)
  err = assert_raises error_class, &block
  assert_match(/#{expected_message}/, err.message) unless expected_message.nil?
end

validate = ShipEngine::Utils::Validate
exceptions = ShipEngine::Exceptions

describe 'Assertion testing' do
  field_name = 'my_field'
  it 'should validate an array of strings' do
    assert_error_message(exceptions::InvalidFieldValue, "#{field_name} must be an Array.") do
      validate.array_of_str(field_name, 'not_a_string_array')
    end
  end

  it 'should validate a hash' do
    validate.hash(field_name, { name: 'hash' })
    assert_error_message(exceptions::InvalidFieldValue, 'must be Hash.') do
      validate.hash(field_name, 'foo')
    end

    assert_error_message(exceptions::FieldValueRequired) do
      validate.hash(field_name, nil)
    end
  end

  it 'should validate a non-whitespace-string' do
    validate.non_whitespace_str(field_name, 'hello')
    validate.non_whitespace_str(field_name, ' hello ')
    assert_error_message(exceptions::InvalidFieldValue, 'cannot be all whitespace.') do
      validate.non_whitespace_str(field_name, '  ')
      validate.non_whitespace_str(field_name, '')
    end
  end
end
