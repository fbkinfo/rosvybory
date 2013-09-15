# encoding: utf-8

require "bundler/capistrano"
require "rvm/capistrano"

set :application, "rosvybory"
set :repository,  "git@github.com:fbkinfo/rosvybory.git"
set :use_sudo, false
set :deploy_via, :remote_cache
default_run_options[:pty] = true
set :rvm_ruby_string, "2.0.0-p247@rosvybory"#:local

set :stages, %w(production staging new callcenter)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

if ENV['LOCAL']
  set :deploy_via, :copy
  set :repository, '.'
  set :scm, :none
end

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

task :build_symlinks, :roles => :app do
  run "rm -f #{release_path}/config/database.yml; ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "rm -f #{release_path}/config/unicorn.rb; ln -s #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
  run "ln -s #{shared_path}/api #{release_path}/public/api"
end

task :create_shared_dirs do
  run "mkdir -p #{shared_path}/api"
end

after "deploy:setup", "create_shared_dirs"

after "deploy:update_code", "build_symlinks"
load 'deploy/assets'
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
  dump_file = File.new "/tmp/rosvybory.dump", "w+"
  run "PGPASSWORD=8wR2gH9hlI pg_dump -h localhost -U dev rosvibory_production --no-owner --no-privileges" do |channel, stream, data|
    trap("INT") { puts 'Interupted'; exit 0; }
    dump_file.write data
    if stream == :err
      puts "Stream error"
      break
    end
  end
  dump_file.close
  system "bundle exec rake db:drop db:create"
  system "psql -d rosvibory_development -U postgres -h localhost < /tmp/rosvybory.dump"
  system "bundle exec rake db:migrate"
  system "bundle exec rake db:drop db:create db:migrate RAILS_ENV=test"
end

require './config/boot'
require 'honeybadger/capistrano'
