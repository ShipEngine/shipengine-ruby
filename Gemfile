# frozen_string_literal: true

source 'https://rubygems.org'

group :development do
  gem 'guard'
  gem 'guard-minitest'
  gem 'pry'
  gem 'solargraph', require: false
  gem 'yard'
end

group :test do
  gem 'minitest'
  gem 'minitest-fail-fast'
  gem 'minitest-focus'
  gem 'minitest-hooks'
  gem 'minitest-line'
  gem 'minitest-reporters'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :test, :development do
  gem 'rake'
  gem 'rubocop', require: false
end

gemspec
