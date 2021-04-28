# frozen_string_literal: true

source 'https://rubygems.org'

group :development do
  gem 'solargraph', require: false
  gem 'guard'
  gem 'guard-minitest'
end

group :test do
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'simplecov', require: false
end

group :test, :development do
  gem 'rake'
  gem 'reek', require: false
  gem 'pry'
  gem 'rubocop', require: false
end

gemspec
