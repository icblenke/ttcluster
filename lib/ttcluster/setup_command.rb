#--
# lib/ttcluster/setup_command.rb
#++


require 'socket'
require 'digest/sha1'
require 'yaml'
require 'ttcluster/base_command'


module TTCluster

  ##
  # 'setup' command implementation.
  class SetupCommand < BaseCommand

    ##
    # Save runner, server, master for 'setup' run.
    def initialize(runner, server, master)
      super(runner)
      @server = server
      @master = master
    end

    ##
    # Setup ttcluster directory and server configuration.
    def run
      chdir_to_ttbase

      server_host, server_port = parse_server(@server)
      master_host, master_port = parse_master(@master)

      setup_directory(server_port)
      config = convert_to_config(server_host, server_port, master_host, master_port)
      save_config(server_port, config)

      puts "TTCluster Setup:"
      puts "  server: #{@server} (sid=#{config[SERVER_KEY][SID_KEY]})"
      puts "  master: #{@master} (sid=#{config[MASTER_KEY][SID_KEY]})"
    end

    protected
    def parse_server(server)
      host, port = server.split(':')[0,2]

      host_ip  = IPSocket.getaddress(host) rescue nil
      local_ip = IPSocket.getaddress('localhost') rescue nil
      node_ip  = IPSocket.getaddress(Socket.gethostname) rescue nil

      error(ERR_SERVER_HOST % host) unless host_ip && (host_ip==local_ip || host_ip==node_ip)
      error(ERR_SERVER_PORT % port) unless %r{^\d+$} =~ port && !File.exists?(port_to_data_dir(port.to_i))

      [host, port.to_i]
    end

    def parse_master(master)
      host, port = master.split(':')[0,2]

      error(ERR_MASTER_HOST % host) unless (Socket.gethostbyname(host) rescue nil)
      error(ERR_MASTER_PORT % port) unless %r{^\d+$} =~ port

      [host, port.to_i]
    end

    def setup_directory(port)
      begin
        mkdirs_with_check(DATA_DIR, LOGS_DIR, PIDS_DIR)
        Dir.mkdir port_to_data_dir(port)
        Dir.mkdir port_to_ulog_dir(port)
      rescue
        error(ERR_MKDIR % $!, 1)
      end
    end

    def mkdirs_with_check(*dirs)
      dirs.each do |dir|
        Dir.mkdir dir unless File.exists?(dir) && File.directory?(dir)
      end
    end

    def convert_to_config(server_host, server_port, master_host, master_port)
      server_config = {
        HOST_KEY  => server_host,
        PORT_KEY  => server_port,
        SID_KEY   => convert_to_sid(server_host, server_port),
        PARAM_KEY => DEFAULT_DB_PARAMS,
        ULIM_KEY  => DEFAULT_ULOG_LIMIT,
        UAS_KEY   => DEFAULT_ULOG_ASYNC
      }
      master_config = {
        HOST_KEY => master_host,
        PORT_KEY => master_port,
        SID_KEY  => convert_to_sid(master_host, master_port)
      }
      config = {
        SERVER_KEY => server_config,
        MASTER_KEY => master_config
      }
    end

    def convert_to_sid(host, port)
      Digest::SHA1.hexdigest("#{host}:#{port}").to_i(16) & ((1<<31)-1)
    end

    def save_config(port, config)
      open(port_to_config_file(port), "w") do |f|
        f.write YAML.dump(config)
      end
    end
  end

end

