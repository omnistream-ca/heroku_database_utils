module HerokuDatabaseUtils
  class Sanitize
    def initialize options
      @options = options
    end

    def run
      return if @options.blank?

      @options.each do |operation, operation_options|
        next if operation == 'replacements'
        if operation_options.present?
          self.send operation, operation_options
        end
      end
    end

    private

    def clear_table tables
      tables.each do |table_name|
        execute "DELETE FROM #{table_name}"
      end
    end

    def email columns
      replacement = @options['replacement_email_username'].presence ||
        `whoami`.strip

      columns.each do |col|
        table, attr = col.split '.'
        exec_col col, """
          UPDATE #{table}
          SET #{attr} =
            '#{replacement}+' ||
              SUBSTRING(#{attr} FROM '^[^@]*') ||
              '.' ||
              SUBSTRING(#{attr} FROM '[^@]*$') ||
              '@localhost'
        """
      end
    end

    def password columns
      replacement = @options['replacement_password'].presence ||
        '$2a$10$vd.f536.MwLSKBoU/BciEOlzVr7VAkeIfBsMnndvbMlsVYqF7dazW'

      columns.each do |col|
        table, attr = col.split '.'
        exec_col col, """
          UPDATE #{table}
          SET #{attr} = '#{replacement}'
        """
      end

    end

    def phone_number columns
      columns.each do |col|
        table, attr = col.split '.'
        exec_col col, """
          UPDATE #{table}
          SET #{attr} = '888' || LPAD('' || id, 7, '0')
        """
      end
    end

    def clear columns
      columns.each do |col|
        table, attr = col.split '.'
        exec_col col, """
          UPDATE #{table}
          SET #{attr} = NULL
        """
      end
    end

    def text columns
      columns.each do |col|
        table, attr = col.split '.'
        exec_col col, """
          UPDATE #{table}
          SET #{attr} = TRANSLATE(
            #{attr},
            'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
            'xxxxxxxxxxxxxxxxxxxxxxxxxxXXXXXXXXXXXXXXXXXXXXXXXXXXYYYYYYYYYY'
          )
        """
      end

    end

    def unique columns
      columns.each do |col|
        table, attr = col.split '.'
        exec_col col, """
          UPDATE #{table}
          SET #{attr} = '#{attr}' || id
        """
      end
    end

    def exec_col col, sql
      print "Sanitizing #{col}..."
      execute sql.gsub(/\s+/, ' ').strip
      puts " done"
    end

    def execute *args
      ActiveRecord::Base.connection.execute *args
    end
  end
end
