#--
# lib/ttcluster/start_command.rb
#++


require 'ttcluster/base_command'


module TTCluster

  ##
  # 'start' command implementation.
  class StartCommand < BaseCommand

    ##
    # Save runner and port for 'start' run.
    def initialize(runner, port)
      super(runner)
      @port = port
    end

    ##
    # Start ttcluster server.
    def run
      chdir_to_ttbase

      statuses = get_statuses(@port)

      puts "TTCluster Start:"
      statuses.each do |port, status|
        msg =
        case status
        when /^running pid\((\d+)\)/
          MSG_SERVER_ALREADY_RUNNING % $1
        when /^mismatch pid\((\d+)\)/
          pid = $1
          remove_pid_file(port)
          if stop_server(pid.to_i)
            pid = start_server(port)
            pid>0 ? (MSG_STARTED_SERVER % pid) : MSG_FAILED_TO_START_SERVER
          else
            MSG_FAILED_TO_STOP_MISMATCH_SERVER % pid
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

