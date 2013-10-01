# encoding: utf-8

require "bundler/capistrano"
require "rvm/capistrano"

set :application, "rosvybory"
set :repository,  "git@github.com:fbkinfo/rosvybory.git"
set :use_sudo, false
set :deploy_via, :remote_cache
default_run_options[:pty] = true
set :rvm_ruby_string, "2.0.0-p247@rosvybory"#:local

set :stages, %w(production staging callcenter)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

if ENV['LOCAL']
  set :deploy_via, :copy
  set :repository, '.'
  set :scm, :none
end

task :build_symlinks, :roles => :app do
  run "rm -f #{release_path}/config/database.yml; ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  run "rm -f #{release_path}/config/unicorn.rb; ln -s #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
  run "rm -f #{release_path}/config/config.yml; ln -s #{shared_path}/config/config.yml #{release_path}/config/config.yml"
  run "rm -f #{release_path}/config/newrelic.yml; ln -s #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
  run "ln -s #{shared_path}/api #{release_path}/public/api"
end

task :create_shared_dirs do
  run "mkdir -p #{shared_path}/api"
end

after "deploy:setup", "create_shared_dirs"

after "deploy:update_code", "build_symlinks"
load 'deploy/assets'
after "deploy:update_code", "deploy:migrate"


desc "Копирование продакшн бд в development и test окружения"
task :dump_and_load_database, :roles => :app do
  dump_file = File.new "/tmp/rosvybory.dump", "w+"
  run "PGPASSWORD=you_password_here pg_dump -h localhost -U dev rosvibory_production --no-owner --no-privileges" do |channel, stream, data|
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
