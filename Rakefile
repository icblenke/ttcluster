#
# Rakefile for ttcluster gem
#

##
# Required Libraries
require 'rubygems'
require 'rake/testtask'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/gempackagetask'

load './ttcluster.gemspec'


##
# Add Task Dependency
task :default => [:test]


##
# Test Task
Rake::TestTask.new do |t|
  t.test_files = GEM_SPEC.test_files
  t.verbose = true
end


##
# RDoc Tasks
Rake::RDocTask.new do |t|
  t.main  = RDOC_MAIN
  t.title = RDOC_TITLE
  t.rdoc_files.include(*GEM_SPEC.extra_rdoc_files)
end


##
# Gem Package Tasks
Rake::GemPackageTask.new(GEM_SPEC) do |pkg|
  pkg.need_tar_gz = true
end

