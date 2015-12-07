require 'rubygems'
require 'daemons'

pwd  = File.dirname(File.expand_path(__FILE__))
file = pwd + '/server.rb'

Daemons.run_proc(
  'server', # name of daemon
#  :dir_mode => :normal
#  :dir => File.join(pwd, 'tmp/pids'), # directory where pid file will be stored
#  :backtrace => true,
#  :monitor => true,
  :log_output => true
) do
  exec "ruby #{file}"
end
