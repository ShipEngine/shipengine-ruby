# frozen_string_literal: true
module ShipEngine
  module Domain
    class Labels
      module VoidLabel
        class Response
          attr_reader :approved, :message

          def initialize(approved:, message:)
            @approved = approved
            @message = message
          end
        end
      end
    end
  end
end
