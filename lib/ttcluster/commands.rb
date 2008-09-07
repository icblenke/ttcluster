#--
# lib/ttcluster/commands.rb
#++

module TTCluster

  ##
  # require 'ttcluster/commands' loads all commands class.
  def require_all_commands
    dir = File.dirname(File.expand_path(__FILE__))
    Dir.glob(File.join(dir, "*_command.rb")).each do |cmd|
      cmd =~ %r{/([^/]+)\.rb$}
      require "ttcluster/#{$1}"
    end
  end

  module_function :require_all_commands
end

TTCluster.require_all_commands

