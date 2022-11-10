namespace :figaro do
  desc "Configure Heroku according to application.yml"
  task :heroku, [:app] => :environment do |_, args|
    Rake::Task["cloud:applications:scale:zero"].invoke
  end
end

namespace :figjam do
  desc "Configure Heroku according to application.yml"
  task :heroku, [:app] => :environment do |_, args|
    Figjam::Tasks::Heroku.new(args[:app]).invoke
  end
end
