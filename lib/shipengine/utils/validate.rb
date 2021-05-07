# frozen_string_literal: true

require 'shipengine/exceptions'

module ShipEngine
  module Utils
    module Validate
      class << self
        def not_nil(field, value)
          raise Exceptions::FieldValueRequired, field if value.nil?
        end

        def str(field, value)
          not_nil(field, value)
          raise Exceptions::InvalidParams, "#{field} must be a String." unless value.is_a?(String)
        end

        def non_empty_str(field, value)
          str(field, value)
          raise Exceptions::InvalidParams, "#{field} cannot be empty." if value.empty?
        end

        def non_whitespace_str(field, value)
          str(field, value)
          raise Exceptions::InvalidParams, "#{field} cannot be all whitespace." if value.strip.empty?
        end

        def hash(field, value)
          not_nil(field, value)
          raise Exceptions::InvalidParams, "#{field} must be Hash." unless value.is_a?(Hash)
        end

        def bool(field, value)
          not_nil(field, value)
          raise Exceptions::InvalidParams, "#{field} must be a Boolean." unless [true, false].include?(value)
        end

        def number(field, value)
          not_nil(field, value)
          raise Exceptions::InvalidParams, "#{field} must be Numeric." unless value.is_a?(Numeric)
        end

        def int(field, value)
          number(field, value)
          raise Exceptions::InvalidParams, "#{field} must be a whole number." unless value.to_i == value
        end

        def non_neg_int(field, value)
          int(field, value)
          raise Exceptions::InvalidParams, "#{field} must be zero or greater." unless value > -1
        end

        def positive_int(field, value)
          non_neg_int(field, value)
          raise Exceptions::InvalidParams, "#{field} must be greater than zero." unless value.positive?
        end

        def array(field, value)
          not_nil(field, value)
          raise Exceptions::InvalidParams, "#{field} must be an Array." unless value.is_a?(Array)
        end

        def array_of_str(field, value)
          array(field, value)
          [field].each do |v|
            raise Exceptions::InvalidParams, "#{field} must be an Array of Strings." unless v.is_a?(String)
          end
        end

        def validate_input_address(address); end
    end
    end
  end
end
