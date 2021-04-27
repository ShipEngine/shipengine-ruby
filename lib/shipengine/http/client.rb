# frozen_string_literal: true

require 'faraday'

module ShipEngine
    class PlatformClient
      attr_accessor :connection

      def initialize(base_url = 'https://simengine.herokuapp.com')
        default_headers = { 'Content-Type' => 'application/json' }
        @connection = Faraday.new(url: base_url, headers: default_headers) do |f|
          f.request :json
          f.response :json
          f.request :retry # retry transient failures
          f.headers = headers || {}
          f.adapter Faraday.default_adapter
        end
      end

      def make_request(method:, route:, body: nil, params: nil)
        data = method == 'GET' ? params : body
        response = @connection[method].call(request.method.downcase.to_sym, route, data)
        response.body
        ShipEngine()
      end
  end
end
