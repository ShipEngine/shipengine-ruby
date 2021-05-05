# frozen_string_literal: true

require 'test_helper'

describe 'Configuration test' do
  it 'Should set configuration' do
    client = ShipEngine::Client.new(api_key: 'hello')

    client.configuration.api_key = 123
    assert client.configuration.api_key == 123

  end
  it 'Should set base_url' do
    client = ShipEngine::Client.new(api_key: 'hello')

    client.configuration.base_url = "http://asfasfasfasfasfasf.com"

  end
end
