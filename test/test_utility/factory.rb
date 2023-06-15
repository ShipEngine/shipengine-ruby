# frozen_string_literal: true

require 'json'

module Factory
  class << self
    def valid_package_id_accepted
      'pkg_1FedAccepted'
    end

    def valid_address_params
      [{
        address_line1: '104 Foo Street', postal_code: '78751', country_code: 'US'
      }]
    end

    def rate_limit_address_params
      [{ address_line1: '429 Rate Limit Error', postal_code: '78751', country_code: 'US' }]
    end

    def invalid_address_params
      [{ address_line1: nil, postal_code: '78751', country: 'US' }]
    end

    def valid_address_res
      [{
        status: 'verified',
        original_address: {
          name: nil,
          company_name: nil,
          address_line1: '4 Jersey St.',
          address_line2: 'Suite 200',
          address_line3: '2nd Floor',
          phone: nil,
          city_locality: 'Boston',
          state_province: 'MA',
          postal_code: '02215',
          country_code: 'US',
          address_residential_indicator: 'unknown'
        },
        matched_address: {
          name: nil,
          company_name: nil,
          address_line1: '4 JERSEY ST STE 200',
          address_line2: '',
          address_line3: '2ND FLOOR',
          phone: nil,
          city_locality: 'BOSTON',
          state_province: 'MA',
          postal_code: '02215-4148',
          country_code: 'US',
          address_residential_indicator: 'no'
        },
        messages: []
      }]
    end

    def valid_address_res_json
      JSON.generate(Factory.valid_address_res)
    end

    def rate_limit_error
      result = {
        request_id: '7b80b28f-80d2-4175-ad99-7c459980539f',
        errors: [
          {
            error_source: 'shipengine',
            error_type: 'system',
            error_code: 'rate_limit_exceeded',
            message:
              'You have exceeded the rate limit. Please see https://www.shipengine.com/docs/rate-limits'
          }
        ]
      }
      JSON.generate(result)
    end
  end
end
