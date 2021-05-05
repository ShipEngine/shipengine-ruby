# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rubocop/rake_task'
require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

RuboCop::RakeTask.new(:lint) do |t|
  t.options = ['--display-cop-names']
end

RuboCop::RakeTask.new(:fix) do |t|
  t.options = ['--auto-correct-all']
end

task :default do
  Rake::Task['test'].execute
  Rake::Task['lint'].execute
end
