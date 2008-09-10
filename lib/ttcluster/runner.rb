#--
# lib/ttcluster/runner.rb
#++


require 'optparse'
require 'etc'
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
      init_user
      cmd = parse_options
      switch_user
      kls = TTCluster.const_get("#{cmd.capitalize}Command")
      arg = cmd == "setup" ? ARGV[1,2] : ["#{ARGV[1]||'all'}"]
      kls.new(self, *arg).run
    end

    protected
    def init_ttbase
       dir = ENV[TTBASE] || (Process.uid==0 ? ROOT_TTBASE : USER_TTBASE)
       @ttbase = File.expand_path dir
    end

    def init_user
      @user = nil
    end

    def parse_options
      # check command-line options
      opts = OptionParser.new do |opts|
        opts.summary_width = 15
        opts.banner = "#{TTCluster::SUMMARY} (#{TTCluster::VERSION})\n\n",
                      "usage: ttcluster setup host:port mhost:mport\n",
                      "       ttcluster {start|stop|restart|status|config|hup} [port|all]\n",
                      "       ttcluster [-h|--help] [-v|--version]\n"
        opts.separator ""
        opts.separator "command options:"
        opts.on("-u", "--user USER") {|user| @user = user}
        opts.on("-d", "--dir  DIR") {|dir| @ttbase = File.expand_path dir}
        opts.separator ""
        opts.separator "misc. options:"
        opts.on_tail("-h", "--help", "Show usage")      { help(opts) }
        opts.on_tail("-v", "--version", "Show version") { version }
      end
      opts.parse! rescue help(opts,1)

      # check command syntax
      case ARGV[0]
      when nil
        help(opts)
      when /^(start|stop|restart|status|config|hup)$/
        error(ERR_COMMAND_ARGUMENT % ARGV[0], 1) unless (1..2).include?(ARGV.size)
      when /^setup$/
        error(ERR_COMMAND_ARGUMENT % ARGV[0], 1) unless ARGV.size==3
      else
        error(ERR_ILLEGAL_COMMAND % ARGV[0], 1)
      end

      ARGV[0] # /^(setup|start|restart|stop|status|config|hup)$/
    end

    def switch_user
      return unless @user
      uid, gid = lambda {|pw| [pw.uid, pw.gid]}[Etc.getpwnam(@user)]
      Process.egid = gid
      Process.euid = uid
    rescue ArgumentError
      error(ERR_ILLEGAL_USER % @user, 1)
    rescue Errno::EPERM
      error(ERR_SWITCH_USER  % @user, 1)
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

