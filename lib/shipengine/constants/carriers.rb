module ShipEngine
  module Constants
    class Carriers
      @carriers = [
        ['ups', 'United Parcel Service'],
        %w[fedex FedEx],
        ['usps', 'U.S. Postal Service'],
        ['ups', 'United Parcel Service']
      ]

      # @param carrier_code [String] - e.g 'ups' | 'fedex' | 'usps'
      # @return String - e.g. 'U.S. Postal Service'
      def self.get_carrier_name_by_code(carrier_code)
        return nil unless carrier_code

        _, name = carriers.find { |code, _| carrier_code.downcase == code } || []
        name
      end
    end
  end
end
