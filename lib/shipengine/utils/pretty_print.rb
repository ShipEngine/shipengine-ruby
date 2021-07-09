# frozen_string_literal: true

require "json"

module ShipEngine
  module Utils
    module PrettyPrint
      def to_s
        JSON.pretty_generate(to_hash)
      end

      def to_hash
        hash = {}
        instance_variables.each do |n|
          hash[n.to_s.delete("@")] = instance_variable_get(n)
        end
        hash
      end
    end
  end
end
