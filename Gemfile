# frozen_string_literal: true

source "https://rubygems.org"

group :development do
  gem "guard"
  gem "guard-minitest"
  gem "pry"
  gem "solargraph", require: false
  gem "yard"
  gem "debase", require: false
  gem "ruby-debug-ide", require: false
  gem "rubocop-shopify", require: false
  gem "awesome_print"
  gem "overcommit"
end

group :test do
  gem "minitest"
  gem "minitest-fail-fast"
  gem "minitest-focus"
  gem "minitest-hooks"
  gem "minitest-line"
  gem "minitest-tagz"
  gem "minitest-reporters"
  gem "simplecov", require: false
  gem "webmock"
  gem "spy"
end

group :test, :development do
  gem "rake"
  gem "rubocop", require: false
end

gemspec
