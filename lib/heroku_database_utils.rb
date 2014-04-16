require "heroku_database_utils/version"
require 'heroku_database_utils/railtie' if defined?(Rails)

require "heroku_database_utils/hdb_backup"
require "heroku_database_utils/hdb_sanitize"
require "heroku_database_utils/hdb_validate"

module HerokuDatabaseUtils
  def options
    @options ||= YAML.load(File.read('config/heroku_database_utils.yml')).with_indifferent_access
  end
end
