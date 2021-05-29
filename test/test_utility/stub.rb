
require ''

module Stub
  class << self
    def jsonrpc(headers: {})
      stub = stub(:post, ShipEngine::Constants::SIMENGINE_URL).with(body: /.*/, headers: headers)
      stub
    end
  end
end
