Rake::Task["db:setup"].clear
desc "Create the database, setup hstore, load the schema, and initialize with the seed data (use db:reset to also drop the db first)"
task "db:setup" => ['db:create', 'setup_postgres_hstore' ,'db:schema:load', 'db:seed']
