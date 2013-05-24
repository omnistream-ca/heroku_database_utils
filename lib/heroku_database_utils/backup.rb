module HerokuDatabaseUtils
  class Backup
    def dump file_name
      system(
        'pg_dump', '--format=custom', '-w', '-h', p(:host), '-p', p(:port),
        '-U', p(:username), '-f', file_name, p(:database)
      )

      raise "Database dump failed" unless $? == 0
    end

    def restore file_name
      system(
        'pg_restore', '-c', '-w', '-h', p(:host), '-p', p(:port), '-U',
        p(:username), '-d', p(:database), file_name
      )

      raise "Database restore failed" unless $? == 0
    end

    def load_latest_app_backup app
      dump = "#{app}.dump"
      backup_id = `heroku pgbackups --app #{app} | tail -n 1 | awk '{ print $1 }'`.strip
      puts "Using backup ID: #{backup_id}"
      url = `heroku pgbackups:url #{backup_id} --app #{app}`.strip.gsub(/^"|"$/, '')
      raise "Failed to download database dump" if $? != 0

      system('curl', '-s', '-o', dump, url)
      raise "Failed to download database dump" if $? != 0

      system(
        'pg_restore', '-c', '-O', '-w', '-h', p(:host), '-p', p(:port), '-U',
        p(:username), '-d', p(:database), dump
      )
      raise "Failed to restore database dump" if $? != 0

      File.unlink dump
    end

    private

    def p param_name
      @params ||= YAML.load(File.read("config/database.yml"))['development']
      @params[param_name.to_s].to_s
    end

  end
end
