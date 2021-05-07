# frozen_string_literal: true

source 'https://rubygems.org'

group :development do
  gem 'guard'
  gem 'guard-minitest'
  gem 'solargraph', require: false
end

group :test do
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'webmock'
  gem 'simplecov', require: false
end

group :test, :development do
  gem 'pry'
  gem 'rake'
  gem 'reek', require: false
  gem 'rubocop'
end

gemspec
