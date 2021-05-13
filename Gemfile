# frozen_string_literal: true

source 'https://rubygems.org'

group :development do
  gem 'debase', require: false
  gem 'guard'
  gem 'guard-minitest'
  gem 'ruby-debug-ide', require: false
  gem 'solargraph', require: false
end

group :test do
  gem 'color_pound_spec_reporter'
  gem 'minitest'
  gem 'minitest-hooks'
  gem 'minitest-fail-fast'
  gem 'minitest-line'
  gem 'minitest-reporters'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :test, :development do
  gem 'pry'
  gem 'rake'
  gem 'reek', require: false
  gem 'rubocop'
end

gemspec
