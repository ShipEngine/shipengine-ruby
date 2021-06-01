# frozen_string_literal: true
require "shipengine"

module TestUtils
  # @param spy [Spy] - spy from "Spy" library
  # @return [Array<ShipEngine::Emitter::HttpEvent>]
  def get_dispatched_events(spy)
    spy.calls.map { |event| event.args[0] }
  end

  def titlecase
    split(/([[:alpha:]]+)/).map(&:capitalize).join
  end

  def fuzzy_get_header(header_name_str, headers)
    headers[header_name_str] || headers[header_name_str.downcase] || headers[titlecase(header_name_str)]
  end
end
