#
# Tokyo Tyrant Cluster Gem Specification
#


##
# Constants
#
GEM_NAME    = "ttcluster"
PKG_VERSION = "0.1.4"
SUMMARY     = "Tokyo Tyrant cluster administration tool"
DESCRIPTION = SUMMARY
AUTHOR      = "kazutanaka"
EMAIL       = "craqueg@gmail.com"
HOME_PAGE   = "http://github.com/kazutanaka/ttcluster"

RDOC_MAIN   = "README"
RDOC_TITLE  = "Tokyo Tyrant Cluster"


##
# Gem Package Spec
#
GEM_SPEC = Gem::Specification.new do |s|
  s.name             = GEM_NAME
  s.version          = PKG_VERSION
  s.summary          = SUMMARY
  s.description      = DESCRIPTION
  s.platform         = Gem::Platform::RUBY
  s.author           = AUTHOR
  s.email            = EMAIL
  s.homepage         = HOME_PAGE

  s.files            = # MANIFEST
%w(
ChangeLog
MANIFEST
MIT-LICENSE
README
Rakefile
TODO
bin/ttcluster
lib/ttcluster.rb
lib/ttcluster/base_command.rb
lib/ttcluster/commands.rb
lib/ttcluster/config_command.rb
lib/ttcluster/constants.rb
lib/ttcluster/hup_command.rb
lib/ttcluster/restart_command.rb
lib/ttcluster/runner.rb
lib/ttcluster/setup_command.rb
lib/ttcluster/start_command.rb
lib/ttcluster/status_command.rb
lib/ttcluster/stop_command.rb
lib/ttcluster/version.rb
sample/logrotate.sample
sample/monitrc.sample
test/test_ttcluster.rb
ttcluster.gemspec
)
  s.test_files       = s.files.select {|f| f =~ %r|^test/test_.*rb$|}
  s.executables      = s.files.select {|f| f =~ %r|^bin/.*$|}.map {|f| f[4..-1]}

  s.has_rdoc         = true
  s.extra_rdoc_files = [RDOC_MAIN] + s.files.select{|f| f =~ %r|^bin/.*$|} + s.files.select{|f| f =~ %r|^lib/.*\.rb$|}
  s.rdoc_options     = ["--main", RDOC_MAIN, "--title", RDOC_TITLE, "--charset=utf-8"]
end

