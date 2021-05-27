# frozen_string_literal: true

require 'test_helper'
require 'shipengine/exceptions'
require 'shipengine'
require 'json'

include ShipEngine::Subscriber
describe 'EventEmitter' do
  it 'responds to events' do
    methods = EventEmitter.instance_methods
    assert_includes(methods, :on_request_sent)
    assert_includes(methods, :on_request_sent)
    assert_includes(methods, :on_error)
  end
end
