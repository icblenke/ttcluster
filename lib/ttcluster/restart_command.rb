#--
# lib/ttcluster/restart_command.rb
#++


require 'ttcluster/base_command'


module TTCluster

  ##
  # 'restart' command implementation.
  class RestartCommand < BaseCommand

    ##
    # Save runner and port for 'restart' run.
    def initialize(runner, port)
      super(runner)
      @port = port
    end

    ##
    # Restart ttcluster server.
    def run
      chdir_to_ttbase

      statuses = get_statuses(@port)

      puts "TTCluster Restart:"
      statuses.each do |port, status|
        msg =
        case status
        when /^(running|mismatch) pid\((\d+)\)/
          stat, pid = $1, $2
          remove_pid_file(port) if stat == "mismatch"
          if stop_server(pid.to_i)
            sleep 0.2
            pid = start_server(port)
            pid>0 ? (MSG_RESTARTED_SERVER % pid) : MSG_FAILED_TO_RESTART_SERVER
          else
            MSG_FAILED_TO_STOP_SERVER % pid
          end
        when /^not running/
          pid = start_server(port)
          pid>0 ? (MSG_STARTED_SERVER % pid) : MSG_FAILED_TO_START_SERVER
        when /^stale pid\((\d+)\)/
          remove_pid_file(port)
          pid = start_server(port)
          pid>0 ? (MSG_STARTED_SERVER % pid) : MSG_FAILED_TO_START_SERVER
        end

        puts "  port(#{port}) => #{msg}"
      end
    end
  end

end

