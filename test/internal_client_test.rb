# frozen_string_literal: true

require 'test_helper'
require 'shipengine'

describe 'Internal Client Tests' do
  base_url = 'https://simengine.herokuapp.com/jsonrpc'
  describe 'Configuration' do
    it 'should have header: API-Key if api-key passed during initialization' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/, headers: { 'API-Key' => 'foo' })

      client = ::ShipEngine::Client.new(api_key: 'foo')
      client.track_package_by_id('invalid_package_id')
      raise 'should not reach here'
    rescue ShipEngine::Exceptions::ShipEngineError => _e
      assert_requested(stub)
      WebMock.reset!
    end

    it 'should have header: API-Key and global configuration should be able to be changed on class' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/, headers: { 'API-Key' => 'bar' })

      client = ::ShipEngine::Client.new(api_key: 'foo')
      # override "foo"
      client.configuration.api_key = 'bar'

      client.track_package_by_id('invalid_package_id')
      raise 'should not reach here'
    rescue ShipEngine::Exceptions::ShipEngineError => _e
      assert_requested(stub)
      WebMock.reset!
    end

    it 'should have header: API-Key and configuration should be overriddeable on a per-call basis, but the global config should not change' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/, headers: { 'API-Key' => 'baz' })

      client = ::ShipEngine::Client.new(api_key: 'foo')
      # override "foo"
      client.configuration.api_key = 'bar'
      # override "bar"
      client.track_package_by_id('invalid_package_id', { api_key: 'baz' })
      raise 'should not reach here'
    rescue ShipEngine::Exceptions::ShipEngineError => _e
      assert_requested(stub)

      # the global configuration should not be mutated
      assert_equal client.configuration.api_key, 'bar'

      WebMock.reset!
    end
  end
end
