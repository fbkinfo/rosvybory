shared = File.expand_path(File.join(File.dirname(__FILE__), '../../../shared'))

worker_processes 2

timeout 30

preload_app true

pid File.join(shared, 'pids/unicorn.pid')

listen File.join(shared, 'sockets/unicorn.sock'), :backlog => 1024

working_directory File.expand_path(File.join(shared, '../current'))

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
