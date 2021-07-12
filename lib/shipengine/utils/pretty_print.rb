# frozen_string_literal: true

require "json"

module ShipEngine
  module Utils
    module PrettyPrint

      # This will be used to add a *to_s* method override
      # to each class that *includes* the *PrettyPrint* module.
      # This method returns a *JSON String* so one can easily inspect
      # the contents of a given object.
      def to_s
        JSON.pretty_generate(to_hash)
      end

      # This will be used to add a *to_hash* method override
      # to each class that *includes* the *PrettyPrint* module.
      # This will return the class attributes and their values in
      # a *Hash*.
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
