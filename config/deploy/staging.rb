set :user, "ubuntu"
set :deploy_to, "/home/ubuntu/staging/rosvybory"

role :web, "54.213.151.246"
role :app, "54.213.151.246"
role :db,  "54.213.151.246", :primary => true

set :rails_env, 'staging'
set :branch, 'develop'
