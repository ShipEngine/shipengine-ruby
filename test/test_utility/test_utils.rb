# frozen_string_literal: true
require "shipengine"

module TestUtils
  # @param spy [Spy] - spy from "Spy" library
  # @return [Array<ShipEngine::Subscriber::HttpEvent>]
  def get_dispatched_events(spy)
    spy.calls.map { |event| event.args[0] }
  end
end
