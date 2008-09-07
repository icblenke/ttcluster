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

    protected
    def start_server(port)
      config = load_config(port)
      exec_cmd = ttserver_command(config)
      output = `#{exec_cmd}`

      if $?.success?
        sleep 0.1
        read_pid_from_pid_file(port)
      else
        STDERR.puts output
        -1
      end
    rescue
      -1
    end

    def load_config(port)
      config_file = port_to_config_file(port)
      YAML.load File.read(config_file)
    end

    def ttserver_command(config)
      server_host = config[SERVER_KEY][HOST_KEY]
      server_port = config[SERVER_KEY][PORT_KEY]
      server_sid  = config[SERVER_KEY][SID_KEY]
      master_host = config[MASTER_KEY][HOST_KEY]
      master_port = config[MASTER_KEY][PORT_KEY]
      db_params   = config[SERVER_KEY][PARAM_KEY] || ''
      db_params   = db_params[1..-1] while db_params =~ /^#/
      ulog_limit  = config[SERVER_KEY][ULIM_KEY] || ''
      ulog_async  = config[SERVER_KEY][UAS_KEY]
 
      ulog_dir    = File.expand_path port_to_ulog_dir(server_port)
      pid_file    = File.expand_path port_to_pid_file(server_port)
      log_file    = File.expand_path port_to_log_file(server_port)
      rts_file    = File.expand_path port_to_rts_file(server_port)
      dbm_file    = File.expand_path port_to_dbm_file(server_port)

      "ttserver -dmn -host #{server_host} -port #{server_port} -sid #{server_sid} -ulog #{ulog_dir} #{ulog_limit.empty? ? '' : '-ulim '+ulog_limit} #{ulog_async ? '-uas' : ''} -mhost #{master_host} -mport #{master_port} -pid #{pid_file} -log #{log_file} -rts #{rts_file} #{dbm_file}#{db_params.empty? ? '' : '#'+db_params}"
    end
  end

end

