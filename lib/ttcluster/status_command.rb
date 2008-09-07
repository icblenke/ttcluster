#--
# lib/ttcluster/status_command.rb
#++


require 'ttcluster/base_command'


module TTCluster

  ##
  # 'status' command implementation.
  class StatusCommand < BaseCommand

    ##
    # Save runner and port for 'status' run.
    def initialize(runner, port)
      super(runner)
      @port = port
    end

    ##
    # Report ttcluster server status.
    def run
      chdir_to_ttbase

      statuses = get_statuses(@port)

      puts "TTCluster Status:"
      statuses.each do |port, status|
        msg =
        case status
        when /^running pid\((\d+)\)/  then MSG_SERVER_RUNNING % $1
        when /^not running/           then MSG_SERVER_NOT_RUNNING
        when /^mismatch pid\((\d+)\)/ then MSG_MISMATCH_PID % $1
        when /^stale pid\((\d+)\)/    then MSG_STALE_PID % $1
        end

        puts "  port(#{port}) => #{msg}"
      end
    end
  end

end

