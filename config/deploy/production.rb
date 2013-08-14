set :user, "dev"
set :deploy_to, "/home/dev/production/rosvybory"

role :web, "staff4.navalny.ru"
role :app, "staff4.navalny.ru"
role :db,  "staff4.navalny.ru", :primary => true

set :rails_env, 'production'

