# frozen_string_literal: true

source 'https://rubygems.org'

group :development do
  gem 'awesome_print'
  gem 'guard'
  gem 'guard-minitest'
  gem 'overcommit'
  gem 'pry'
  gem 'rubocop-shopify', require: false
  gem 'ruby-debug-ide', require: false
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
  gem 'minitest-tagz'
  gem 'simplecov', require: false
  gem 'spy'
  gem 'webmock'
end

group :test, :development do
  gem 'rake'
  gem 'rubocop', require: false
end

gemspec
