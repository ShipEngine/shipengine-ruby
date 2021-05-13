# frozen_string_literal: true

require 'shipengine/exceptions'

module ShipEngine
  module Utils
    module Validate
      class << self
        def not_nil(field, value)
          return unless value.nil?

          raise Exceptions.create_required_error(field)
        end

        def not_nil_or_empty_str(field, value)
          not_nil(field, value)
          return if value == ''

          raise Exceptions.create_required_error(feld)
        end

        def str(field, value)
          not_nil(field, value)
          return if value.is_a?(String)

          raise Exceptions.create_invalid_field_value_error("#{field} must be a String.")
        end

        def non_empty_str(field, value)
          str(field, value)
          return unless value.empty?

          raise Exceptions.create_invalid_field_value_error("#{field} cannot be empty.")
        end

        def non_whitespace_str(field, value)
          str(field, value)
          return unless value.strip.empty?

          raise Exceptions.create_invalid_field_value_error("#{field} cannot be all whitespace.")
        end

        def hash(field, value)
          not_nil(field, value)
          return if value.is_a?(Hash)

          raise Exceptions.create_invalid_field_value_error("#{field} must be Hash.")
        end

        def bool(field, value)
          not_nil(field, value)
          return if [true, false].include?(value)

          raise Exceptions.create_invalid_field_value_error("#{field} must be a Boolean.")
        end

        def number(field, value)
          not_nil(field, value)
          return if value.is_a?(Numeric)

          raise Exceptions.create_invalid_field_value_error("#{field} must be Numeric.")
        end

        def int(field, value)
          number(field, value)
          return if value.to_i == value

          raise Exceptions.create_invalid_field_value_error("#{field} must be a whole number.")
        end

        def non_neg_int(field, value)
          int(field, value)
          return if value >= 0

          raise Exceptions.create_invalid_field_value_error("#{field} must be zero or greater.")
        end

        def positive_int(field, value)
          int(field, value)
          return if value.positive?

          raise Exceptions.create_invalid_field_value_error("#{field} must be greater than zero.")
        end

        def array(field, value)
          not_nil(field, value)

          return if value.is_a?(Array)

          raise Exceptions.create_invalid_field_value_error("#{field} must be an Array.")
        end

        def array_of_str(field, value)
          array(field, value)
          value.each do |v|
            next if v.is_a?(String)

            raise Exceptions.create_invalid_field_value_error("#{field} must be an Array of Strings.")
          end
        end

        def validate_input_address(address); end
    end
    end
  end
end
