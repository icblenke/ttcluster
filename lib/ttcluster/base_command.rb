#--
# lib/ttcluster/base_command.rb
#++


require 'ttcluster/constants'


module TTCluster

  ##
  # Base class for commands(setup,start,stop,status)
  class BaseCommand
    ##
    # Save runner.
    def initialize(runner)
      @runner = runner
      @ttbase = @runner.ttbase
    end

    protected
    def error(msg=nil, code=1)
      @runner.send :error, msg, code
    end

    def ttbase
      File.expand_path @ttbase
    end

    def chdir_to_ttbase
      msg = !File.directory?(@ttbase)    ? ERR_NOT_DIRECTORY % @ttbase :
            !(File.readable?(@ttbase) &&
              File.writable?(@ttbase) &&
              File.executable?(@ttbase)) ? ERR_NOT_ACCESSIBLE % @ttbase :
                                           nil
      error(msg, 1) if msg
      Dir.chdir @ttbase
    end

    def list_ports(port, check=true)
      ports = []
      if port == 'all'
        ports = Dir['data/*'].select {|path|
          %r{^data/\d+$} =~ path && File.directory?(path)
        }.map {|path|
          path.split('/')[-1].to_i
        }
      elsif port.to_i > 0 && (!check || File.directory?(port_to_data_dir(port.to_i)))
        ports << port.to_i
      end

      error(ERR_NO_PORT_DIR_FOUND % port, 1) if ports.empty?

      ports.sort
    end

    def get_statuses(port0)
      statuses = list_ports(port0).inject({}) do |acc, port|
        acc[port] = port_to_status(port)
        acc
      end

      def statuses.each
        self.keys.sort.each do |port|
          yield [port, self[port]]
        end
      end

      statuses
    end

    def port_to_data_dir(port)
      "#{DATA_DIR}/#{port}"
    end

    def port_to_dbm_file(port)
      "#{port_to_data_dir(port)}/casket.tch"
    end

    def port_to_rts_file(port)
      "#{port_to_data_dir(port)}/timestamp.rts"
    end

    def port_to_config_file(port)
      "#{port_to_data_dir(port)}/config.yml"
    end

    def port_to_ulog_dir(port)
      "#{port_to_data_dir(port)}/ulog"
    end

    def port_to_log_file(port)
      "#{LOGS_DIR}/#{port}.log"
    end

    def port_to_pid_file(port)
      "#{PIDS_DIR}/#{port}.pid"
    end

    def remove_pid_file(port)
      pid_file = port_to_pid_file(port)
      File.delete(pid_file) if File.exists?(pid_file)
    end

    def read_pid_from_pid_file(port)
      open(port_to_pid_file(port)).gets.to_i rescue -1
    end

    def start_server(port)
      config = load_config(port)
      exec_cmd = ttserver_command(config)
      output = `#{exec_cmd}`

      if $?.success?
        sleep 0.2
        read_pid_from_pid_file(port)
      else
        STDERR.puts output
        -1
      end
    rescue
      -1
    end

    def stop_server(pid, signal="TERM")
      Process.kill(signal, pid)
    rescue
      false
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
      ext         = config[SERVER_KEY][EXT]
      extpc       = config[SERVER_KEY][EXT_PC]
 
      ulog_dir    = File.expand_path port_to_ulog_dir(server_port)
      pid_file    = File.expand_path port_to_pid_file(server_port)
      log_file    = File.expand_path port_to_log_file(server_port)
      rts_file    = File.expand_path port_to_rts_file(server_port)
      dbm_file    = File.expand_path port_to_dbm_file(server_port)

      "ttserver -dmn -host #{server_host} -port #{server_port} -sid #{server_sid} -ulog #{ulog_dir} #{ulog_limit.empty? ? '' : '-ulim '+ulog_limit} #{ulog_async ? '-uas' : ''} #{ext ? "-ext #{ext}"} #{extpc ? "-extpc #{extpc}"} -mhost #{master_host} -mport #{master_port} -pid #{pid_file} -log #{log_file} -rts #{rts_file} #{dbm_file}#{db_params.empty? ? '' : '#'+db_params}"
    end

    def port_to_status(port)
      pid = read_pid_from_pid_file(port)
      unless pid>0
        pid2 = find_pid(port)
        return pid2 ? "mismatch pid(#{pid2})" : # no pid file but running
                      "not running"             # no pid file and not running
      end

      ps_out = `ps -o #{ps_cmd_name}= -p #{pid}`

      if ps_out =~ /ttserver/
        "running pid(#{pid})" # valid pid and running
      else
        pid2 = find_pid(port)
        pid2 ? "mismatch pid(#{pid2})" : # invalid pid but running
               "stale pid(#{pid})"       # invalid pid and not running
      end
    end

    def find_pid(port)
      ps_cmd = "ps #{ps_cmd_flags} pid,#{ps_cmd_name}"
      ps_out = `#{ps_cmd}`
      ps_out.each do |line|
        if line =~ /ttserver\s.+-port\s+#{port}\s/
          pid = line.split[0]
          return pid
        end
      end
      nil
    end

    def ps_cmd_name
      RUBY_PLATFORM =~ /solaris|aix/i ? "args" : "command"
    end

    def ps_cmd_flags
      RUBY_PLATFORM =~ /slaris|aix/i ? "-eo" : "-ewwo"
    end
  end

end

