set :user, "dev"
set :deploy_to, "/home/dev/production/rosvybory"

role :web, "staff4.navalny.ru"
role :app, "staff4.navalny.ru"
role :db,  "staff4.navalny.ru", :primary => true

set :rails_env, 'production'

namespace :deploy do
  task :start do
    run "sudo /etc/init.d/unicorn_init start rosvybory_production"
    run "sudo /etc/init.d/rosvybory start"
  end

  task :stop do
    run "sudo /etc/init.d/unicorn_init stop rosvybory_production"
    run "sudo /etc/init.d/rosvybory stop"
  end

  task :restart do
    run "sudo /etc/init.d/unicorn_init stop rosvybory_production"
    run "sudo /etc/init.d/unicorn_init start rosvybory_production"

    run "sudo /etc/init.d/rosvybory stop"
    run "sudo /etc/init.d/rosvybory start"
  end
end

