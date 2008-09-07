#--
# lib/ttcluster/runner.rb
#++


require 'optparse'
require 'ttcluster/commands'
require 'ttcluster/constants'
require 'ttcluster/version'


module TTCluster

  ##
  # 'ttcluster' script runner.
  class Runner
    attr_reader :ttbase

    ##
    # Wrapper of TTCluster::Runner#new.
    def self.run
      new
    end

    ##
    # 'ttcluster' script implementation.
    def initialize
      init_ttbase
      cmd = parse_options
      kls = TTCluster.const_get("#{cmd.capitalize}Command")
      arg = cmd == "setup" ? ARGV[1,2] : ["#{ARGV[1]||'all'}"]
      kls.new(self, *arg).run
    end

    protected
    def init_ttbase
       dir = ENV[TTBASE] || (Process.uid==0 ? ROOT_TTBASE : USER_TTBASE)
       @ttbase = File.expand_path dir
    end

    def parse_options
      # check command-line options
      opts = OptionParser.new do |opts|
        opts.summary_width = 15
        opts.banner = "#{TTCluster::SUMMARY} (#{TTCluster::VERSION})\n\n",
                      "usage: ttcluster setup host:port mhost:mport\n",
                      "       ttcluster {start|stop|status|config|hup} [port|all]\n",
                      "       ttcluster [-h|--help] [-v|--version]\n"
        opts.separator ""
        opts.on_tail("-h", "--help", "Show usage")      { help(opts) }
        opts.on_tail("-v", "--version", "Show version") { version }
      end
      opts.parse! rescue help(opts,1)

      # check command syntax
      case ARGV[0]
      when nil
        help(opts)
      when /^(start|stop|status|config|hup)$/
        error(ERR_COMMAND_ARGUMENT % ARGV[0], 1) unless (1..2).include?(ARGV.size)
      when /^setup$/
        error(ERR_COMMAND_ARGUMENT % ARGV[0], 1) unless ARGV.size==3
      else
        error(ERR_ILLEGAL_COMMAND % ARGV[0], 1)
      end

      ARGV[0] # /^(setup|start|stop|status|config|hup)$/
    end

    def error(msg=nil, code=1)
      STDERR.puts(msg) if msg
      exit code
    end

    def version
      puts "#{TTCluster::SUMMARY} #{TTCluster::VERSION}"
      error(nil,0)
    end

    def help(opts, code=0)
      puts "#{opts}"
      error(nil, code)
    end
  end

end

