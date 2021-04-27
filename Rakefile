# frozen_string_literal: true

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
  t.options = ['--auto-correct']
end

desc 'Open an irb (or pry) session preloaded with this gem'
task :repl do
  require 'pry'
  gem_name = 'shipengine'
  sh %(pry -I lib -r #{gem_name})
rescue LoadError => _e
  sh %(irb -I lib -r #{gem_name})
end

task default: :test
