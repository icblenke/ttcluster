#--
# lib/ttcluster/config_command.rb
#++


require 'ttcluster/base_command'


module TTCluster

  ##
  # 'config' command implementation.
  class ConfigCommand < BaseCommand

    ##
    # Save runner and port for 'config' run.
    def initialize(runner, port)
      super(runner)
      @port = port
    end

    ##
    # Report ttcluster server config.
    def run
      chdir_to_ttbase

      statuses = get_statuses(@port)

      puts "TTCluster config:"
      puts "  ttbase dir => '#{ttbase}'"
      statuses.each do |port, status|
        config = load_config(port)
        msg =
        if config
          <<EOS

    server: #{config[SERVER_KEY][HOST_KEY]}:#{config[SERVER_KEY][PORT_KEY]} (sid=#{config[SERVER_KEY][SID_KEY]})
    master: #{config[MASTER_KEY][HOST_KEY]}:#{config[MASTER_KEY][PORT_KEY]} (sid=#{config[MASTER_KEY][SID_KEY]})
EOS
        else
          MSG_NO_CONFIG_FILE_FOUND
        end

        puts "  port(#{port}) => #{msg}"
      end
    end

    protected
    def load_config(port)
      open(port_to_config_file(port)) do |f|
        YAML.load(f.read)
      end
    rescue
      nil
    end
  end

end

