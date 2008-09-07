#
# Tokyo Tyrant Cluster Gem Specification
#

##
# Library
$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'ttcluster/version'


##
# Constants
AUTHOR     = "Kazuhiro Tanaka"
EMAIL      = "craqueg@gmail.com"
HOME_PAGE  = "~"

RDOC_MAIN  = "README"
RDOC_TITLE = "Tokyo Tyrant Cluster"


##
# Gem Package Spec
GEM_SPEC = Gem::Specification.new do |s|
  s.name             = TTCluster::GEM_NAME
  s.version          = TTCluster::VERSION
  s.summary          = TTCluster::SUMMARY
  s.description      = TTCluster::DESCRIPTION
  s.platform         = Gem::Platform::RUBY

  s.author           = AUTHOR
  s.email            = EMAIL
  s.homepage         = HOME_PAGE

  s.files            = open("MANIFEST").read.split
  s.test_files       = s.files.select {|f| f =~ %r|^test/test_.*rb$|}
  s.executables      = s.files.select {|f| f =~ %r|^bin/.*$|}.map {|f| f[4..-1]}

  s.has_rdoc         = true
  s.extra_rdoc_files = [RDOC_MAIN] + s.files.select{|f| f =~ %r|^bin/.*$|} + s.files.select{|f| f =~ %r|^lib/.*\.rb$|}
  s.rdoc_options     = ["--main", RDOC_MAIN, "--title", RDOC_TITLE, "--charset=utf-8"]
end

