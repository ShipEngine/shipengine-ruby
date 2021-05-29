# frozen_string_literal: true
require "json"

module Factory
  class << self
    def valid_address_params
      {
        street: ["104 Foo Street"], postal_code: "78751", country: "US"
      }
    end
    def rate_limit_address_params
      { street: ["429 Rate Limit Error"], postal_code: "78751", country: "US" }
    end

    def valid_address_res
      {
        jsonrpc: "2.0",
        id: "req_123456",
        result: {
          isValid: true,
          normalizedAddress: {
            name: "",
            company: "",
            phone: "",
            street: [
              "104 NELRAY",
            ],
            cityLocality: "METROPOLIS",
            stateProvince: "ME",
            postalCode: "02215",
            countryCode: "US",
            isResidential: nil,
          },
          messages: [],
        },
      }
    end

    def valid_address_res_json
      JSON.generate(Factory.valid_address_res)
    end

    def rate_limit_error(data: {})
      result = {
        jsonrpc: "2.0",
        id: "req_123456",
        error: {
          code: -32_603,
          message: "You have exceeded the rate limit.",
          data: {
            source: "shipengine",
            type: "system",
            code: "rate_limit_exceeded",
            url: "https://www.shipengine.com/docs/rate-limits",
            retryAfter: 0,
          }.merge(data),
        },
      }
      JSON.generate(result)
    end
  end
end
