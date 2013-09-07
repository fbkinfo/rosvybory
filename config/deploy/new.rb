set :user, "dev"
set :deploy_to, "/home/dev/production/rosvybory"

role :web, "54.200.5.197"
role :app, "54.200.5.197"
role :db,  "54.200.5.197", :primary => true

set :rails_env, 'production'
set :branch, 'master'

namespace :deploy do
  task :start do
    run "sudo /etc/init.d/unicorn_init start rosvybory_production"
    run "sudo /etc/init.d/rosvybory start"
  end

  task :stop do
    run "sudo /etc/init.d/unicorn_init stop rosvybory_production"
    run "sudo stop rosvybory"
    run "sudo kill `ps aux | grep [r]esque | grep -v grep | cut -c 10-16`"
  end

  task :restart do
    run "sudo /etc/init.d/unicorn_init stop rosvybory_production"
    run "sudo /etc/init.d/unicorn_init start rosvybory_production"

    run "sudo stop rosvybory"
    run "sudo kill `ps aux | grep [r]esque | grep -v grep | cut -c 10-16`"
    run "sudo /etc/init.d/rosvybory start"
  end
end

