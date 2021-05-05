# frozen_string_literal: true

# More info at https://github.com/guard/guard#readme
guard :minitest do
  watch(%r{^test/(.*)_test\.rb$}) { 'test' }
  watch(%r{^lib/(.*)\.rb$})  { 'test' } # run all tests
  watch(%r{^test/test_helper\.rb$}) { 'test' }
end
