require 'test_helper'
require 'shipengine'

describe 'Internal Client Tests' do
  it 'should have header: API-Key' do
    stub = stub_request(:post, 'https://simengine.herokuapp.com/jsonrpc')
    .with(body: /.*/,headers: { 'API-Key' =>  'foo'})

    client = ::ShipEngine::Client.new(api_key: 'foo')
    client.track_package_by_id("pkg_1234567")
    # Ignore any API errors since we don't care about the response, just the request fields
  rescue ShipEngine::Exceptions::ShipEngineError => _
    assert_requested(stub)
    WebMock.reset!
  end
end
