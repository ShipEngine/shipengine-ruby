# frozen_string_literal: true

module ShipEngine
  module Utils
    class PrettyPrint
      def self.to_s
        hash = {}
        instance_variables.each { |n| hash[n.to_s.delete("@")] = instance_variable_get(n) }
        hash
      end
    end
  end
end
