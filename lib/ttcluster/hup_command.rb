#--
# lib/ttcluster/hup_command.rb
#++


require 'ttcluster/base_command'


module TTCluster

  ##
  # 'hup' command implementation.
  class HupCommand < BaseCommand

    ##
    # Save runner and port for 'hup' run.
    def initialize(runner, port)
      super(runner)
      @port = port
    end

    ##
    # Send HUP signal to ttcluster server.
    def run
      chdir_to_ttbase

      statuses = get_statuses(@port)

      puts "TTCluster Hup:"
      statuses.each do |port, status|
        msg =
        case status
        when /^running pid\((\d+)\)/
          (stop_server($1.to_i, "HUP") ? MSG_HUP_SERVER : MSG_FAILED_TO_HUP_SERVER) % $1
        when /^not running/           then MSG_SERVER_NOT_RUNNING
        when /^mismatch pid\((\d+)\)/ then MSG_MISMATCH_PID % $1
        when /^stale pid\((\d+)\)/    then MSG_STALE_PID % $1
        end

        puts "  port(#{port}) => #{msg}"
      end
    end
  end

end

