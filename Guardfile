# frozen_string_literal: true

# More info at https://github.com/guard/guard#readme
guard :minitest do
  watch(%r{^lib/(.*)\.rb$}) { 'test' } # run all tests if code is modified
  watch(%r{^test/(.*)_test\.rb$}) # only run specific test file if test is modified

  # configuration
  watch(%r{^test/test_helper\.rb$}) { 'test' }
  watch(%r{^test/test_utility/(.*)\.rb$}) { 'test' }
end
