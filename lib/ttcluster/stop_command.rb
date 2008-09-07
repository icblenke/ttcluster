#--
# lib/ttcluster/stop_command.rb
#++


require 'ttcluster/base_command'


module TTCluster

  ##
  # 'stop' command implementation.
  class StopCommand < BaseCommand

    ##
    # Save runner and port for 'stop' run.
    def initialize(runner, port)
      super(runner)
      @port = port
    end

    ##
    # Stop ttcluster server.
    def run
      chdir_to_ttbase

      statuses = get_statuses(@port)

      puts "TTCluster Stop:"
      statuses.each do |port, status|
        msg =
        case status
        when /^(running|mismatch) pid\((\d+)\)/
          (stop_server($2.to_i) ? MSG_STOPPED_SERVER : MSG_FAILED_TO_STOP_SERVER) % $2
        when /^not running/
          MSG_SERVER_NOT_RUNNING
        when /^stale pid\((\d+)\)/
          remove_pid_file(port)
          MSG_STALE_PID % $1
        end

        puts "  port(#{port}) => #{msg}"
      end
    end
  end

end

