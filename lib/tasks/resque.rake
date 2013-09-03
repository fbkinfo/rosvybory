
desc "Fix loading workers"
task "resque:setup" => :environment do
  ENV['QUEUE'] ||= '*'
end
