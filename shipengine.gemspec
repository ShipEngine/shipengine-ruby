# frozen_string_literal: true

require_relative "lib/shipengine/version"

Gem::Specification.new do |spec|
  spec.name          = "shipengine"
  spec.version       = ShipEngine::VERSION
  spec.authors       = ["ShipEngine Development Team"]
  spec.summary       = "The Official Ruby SDK for ShipEngine."
  spec.homepage      = "https://github.com/ShipEngine/shipengine-ruby"
  spec.license       = "Apache-2.0"
  spec.files = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.6"

  spec.add_runtime_dependency("hashie", ">= 3.4")
  spec.add_runtime_dependency("faraday", ">= 1.4")
  spec.add_runtime_dependency("faraday_middleware", ">= 1.0")
end
