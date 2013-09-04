
env = ENV["RAILS_ENV"]

if env == "production"
  RAILS_ROOT = "/home/dev/production/rosvybory/current"
  user 'dev', 'staff'
else
  RAILS_ROOT = "/home/ubuntu/staging/rosvybory/current"
  user 'ubuntu', 'ubuntu'
end

working_directory RAILS_ROOT
shared = File.expand_path("#{RAILS_ROOT}/../shared")

if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
  begin
    require 'rvm'
    RVM.use_from_path! RAILS_ROOT
  rescue LoadError
    raise "RVM ruby lib is currently unavailable."
  end
end

ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
require 'bundler/setup'

worker_processes 2

timeout 60

preload_app true

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

pid File.join(shared, 'pids/unicorn.pid')

listen File.join(shared, 'sockets/unicorn.sock'), :backlog => 1024

stderr_path File.join(shared, 'log/unicorn.error.log')
stdout_path File.join(shared, 'log/unicorn.access.log')

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
