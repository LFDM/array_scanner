require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'coveralls/rake/task'

Coveralls::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '-f d --color'
end

task :default => [:spec, 'coveralls:push']
