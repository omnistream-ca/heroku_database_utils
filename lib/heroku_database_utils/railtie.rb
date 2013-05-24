module HerokuDatabaseUtils
  class Railtie < Rails::Railtie
    railtie_name :heroku_database_utils

    rake_tasks do
      load "tasks/heroku_database_utils.rake"
    end
  end
end
