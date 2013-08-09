# encoding: utf-8

require "bundler/capistrano"
require "rvm/capistrano"

set :application, "rosvybory"
set :repository,  "git@github.com:fbkinfo/rosvybory.git"
set :deploy_to, "/home/dev/production/rosvybory"
set :user, "dev"
set :use_sudo, false
set :deploy_via, :remote_cache
default_run_options[:pty] = true
set :rvm_ruby_string, "2.0.0-p247@rosvybory"#:local

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "staff4.navalny.ru"                          # Your HTTP server, Apache/etc
role :app, "staff4.navalny.ru"                          # This may be the same as your `Web` server
role :db,  "staff4.navalny.ru", :primary => true # This is where Rails migrations will run

after "deploy:update_code", "deploy:migrate"
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

desc "Копирование продакшн бд в development и test окружения"
task :dump_and_load_database, :roles => :app do
  dump_file = File.new "/tmp/passport.dump", "w+"
  run "PGPASSWORD=volunteeria pg_dump -h localhost -U rosvybory rosvybory_production --no-owner --no-privileges" do |channel, stream, data|
    trap("INT") { puts 'Interupted'; exit 0; }
    dump_file.write data
    if stream == :err
      puts "Stream error"
      break
    end
  end
  dump_file.close
  system "bundle exec rake db:drop db:create"
  system "psql -d volunteeria_development -U postgres -h localhost < /tmp/passport.dump"
  system "bundle exec rake db:migrate"
  system "bundle exec rake db:drop db:create db:migrate RAILS_ENV=test"
end

        require './config/boot'
        require 'honeybadger/capistrano'
