namespace :hdb do
  include HerokuDatabaseUtils

  namespace :development do
    desc "Backup the current contents of the development database"
    task :backup do
      print "Creating development backup..."
      Backup.new.dump options[:development_backup_path]
      puts " done"
    end

    task :backup_unless_present do
      if ! File.file? options[:development_backup_path]
        Rake::Task['hdb:development:backup'].invoke
      end
    end

    desc "Restore the development database"
    task :restore do
      print "Restoring development backup..."
      Backup.new.restore options[:development_backup_path]
      puts " done"
      File.unlink options[:development_backup_path]
    end

    desc "Validate all of the records in the development database"
    task :validate => :environment do
      if Validate.new(options[:validate]).run
        raise "Validation errors"
      end
    end

    desc "Sanitize the development database"
    task :sanitize => :environment do
      Sanitize.new(options[:sanitize]).run
    end

    desc "Resume a validation task on heroku DB replica (to test if update models/migrations fix previous validation run failure"
    task :continue_validation => [
      :"db:migrate",
      :"hdb:development:validate",
      :"hdb:development:restore",
      :"db:schema:dump"
    ]
  end

  options[:instances].each do |ns, heroku_name|
    ns = ns.to_sym

    namespace ns do
      task :load_latest_backup do
        Backup.new.load_latest_app_backup heroku_name
      end

      desc "Load and sanitize the latest backup from #{heroku_name} into the development environment"
      task :load => [
        :"hdb:development:backup_unless_present",
        :"hdb:#{ns}:load_latest_backup",
        :"hdb:development:sanitize"
      ]

      desc "Load, sanitize and validate the latest backup from #{heroku_name} and then restore the development database"
      task :validate => [
        :"hdb:development:backup_unless_present",
        :"hdb:#{ns}:load_latest_backup",
        :"hdb:development:sanitize",
        :"db:migrate",
        :"hdb:development:validate",
        :"hdb:development:restore",
        :"db:schema:dump"
      ]
    end
  end
end
