set :user, "dev"
set :deploy_to, "/home/dev/production/rosvybory"

server 'x.rosvybory.org', :app, :web, :db, :primary => true

set :rails_env, 'production'
set :branch, 'master'

namespace :deploy do
  task :start do
    run "sudo /etc/init.d/unicorn_init start rosvybory_production"
    run "sudo /etc/init.d/rosvybory start"
  end

  task :stop do
    run "sudo /etc/init.d/unicorn_init stop rosvybory_production"
    #run "sudo /etc/init.d/rosvybory stop"
    run "sudo kill `ps aux | grep [r]esque | grep -v grep | cut -c 10-16`"
  end

  task :restart do
    run "sudo /etc/init.d/unicorn_init stop rosvybory_production"
    run "sudo /etc/init.d/unicorn_init start rosvybory_production"

    run "sudo kill `ps aux | grep [r]esque | grep -v grep | cut -c 10-16`"
    #run "sudo /etc/init.d/rosvybory stop" #пока не работает - из-за rvm init.d скрипт, генерируемый через foreman неправильно записывает файл c pid при старте
    run "sudo /etc/init.d/rosvybory start"
  end
end

