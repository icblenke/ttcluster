#--
# lib/ttcluster/constants.rb
#++


module TTCluster

  TTBASE      = "TTBASE".freeze
  ROOT_TTBASE = "/var/ttcluster".freeze
  USER_TTBASE = "~/ttcluster".freeze
  DATA_DIR    = "data".freeze
  LOGS_DIR    = "logs".freeze
  PIDS_DIR    = "pids".freeze

  HOST_KEY   = "host".freeze
  PORT_KEY   = "port".freeze
  SID_KEY    = "sid".freeze
  PARAM_KEY  = "db_params".freeze
  ULIM_KEY   = "ulog_limit".freeze
  UAS_KEY    = "ulog_async".freeze
  SERVER_KEY = "server".freeze
  MASTER_KEY = "master".freeze

  DEFAULT_DB_PARAMS  = "#bnum=2000000#opts=ld".freeze
  DEFAULT_ULOG_LIMIT = "20m".freeze
  DEFAULT_ULOG_ASYNC = false

  MSG_SERVER_RUNNING         = "Server is running (pid=%s)".freeze
  MSG_SERVER_ALREADY_RUNNING = "Server is already running (pid=%s)".freeze
  MSG_SERVER_NOT_RUNNING     = "Server is not running".freeze
  MSG_STARTED_SERVER         = "Started server (pid=%s)".freeze
  MSG_STOPPED_SERVER         = "Stopped server (pid=%s)".freeze
  MSG_HUP_SERVER             = "Hung up server (pid=%s)".freeze
  MSG_FAILED_TO_START_SERVER = "Failed to start server, check port, permissions and configuration".freeze
  MSG_FAILED_TO_STOP_SERVER  = "Failed to stop server (pid=%s), check permissions".freeze
  MSG_FAILED_TO_STOP_MISMATCH_SERVER = "Failed to stop pid mismatch server (pid=%s), check permissions".freeze
  MSG_FAILED_TO_HUP_SERVER   = "Failed to hung up server (pid=%s), check permissions".freeze
  MSG_MISMATCH_PID           = "Pid file is missing or pid mismatch, server is running (pid=%s)".freeze
  MSG_STALE_PID              = "Pid file is stale and invalid (pid=%s), server is not running".freeze
  MSG_NO_CONFIG_FILE_FOUND   = "No config file found".freeze

  ERR_COMMAND_ARGUMENT  = "Command argument mismatch: '%s'".freeze
  ERR_ILLEGAL_COMMAND   = "Illegal command: '%s'".freeze
  ERR_NOT_DIRECTORY     = "Not directory: '%s'".freeze
  ERR_NOT_ACCESSIBLE    = "Not accessible: '%s'".freeze
  ERR_NO_PORT_DIR_FOUND = "No port dir found: '%s'".freeze
  ERR_SERVER_HOST       = "Server host must be localhost or hostname: '%s'".freeze
  ERR_SERVER_PORT       = "Server port illegal or used: '%s'".freeze
  ERR_MASTER_HOST       = "Master host must be lookupable: '%s'".freeze
  ERR_MASTER_PORT       = "Master port illegal: '%s'".freeze
  ERR_MKDIR             = "Failed to mkdir: '%s'".freeze

end

