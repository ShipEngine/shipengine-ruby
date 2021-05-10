# frozen_string_literal: true

require 'test_helper'
require 'shipengine/exceptions'

def assert_api_key_error(err)
  assert_equal 'shipengine', err.source
  assert_equal 'validation', err.type
  assert_equal :field_value_required, err.code
  assert_equal 'A ShipEngine API key must be specified.', err.message
end

describe 'Internal Client Tests' do
  after do
   WebMock.reset!
  end

  base_url = 'https://simengine.herokuapp.com/jsonrpc'
  describe 'Configuration' do
    it 'Should throw a validation error if api_key is nil during instantiation' do
        err = assert_raises ShipEngine::Exceptions::FieldValueRequired do
          ShipEngine::Client.new(api_key: nil)
        end
        assert_api_key_error(err)
    end
    it 'should have header: API-Key if api-key passed during initialization' do
      stub = stub_request(:post, base_url)
             .with(body: /.*/, headers: { 'API-Key' => 'foo' })

      client = ::ShipEngine::Client.new(api_key: 'foo')
      client.track_package_by_id('invalid_package_id')
      raise 'should not reach here'
    rescue ShipEngine::Exceptions::ShipEngineError => _e
      assert_requested(stub)
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

    end
  end
end
