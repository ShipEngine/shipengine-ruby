module ShipEngine
  module Exceptions

    #  standard class - network connection error / internal server error /etc
    class ShipEngineError < StandardError
    end

    # 400 error, or other "user exceptions"
    class ValidationError < ShipEngineError
    end

  end
end
