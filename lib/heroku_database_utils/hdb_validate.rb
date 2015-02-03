module HerokuDatabaseUtils
  class HdbValidate
    def initialize(options = {})
      @options = options
    end

    def run
      puts "Validating all models"
      result = false

      concrete_models.each(&:reset_column_information)
      concrete_models.each do |model|
        rel = model.all
        includes = []
        model.ancestors.each do |klass|
          if incl = @options['includes'].try(:[], klass.to_s)
            includes += incl
          end
        end
        if includes.present?
          includes = symbolize(includes).uniq
          rel = rel.includes(*includes)
        end

        count = model.count
        i = 0
        error_ids = []
        errors = []
        ignore_errors = @options['ignore_errors'].try(:[], model.to_s) || []
        time = Time.now.to_i

        rel.find_each do |record|
          begin
            invalid = record.invalid?
          rescue
            result = true
            error_ids << record.id
            errors |= [
              "Raised \"#{$!.message}\"",
              $!.backtrace.join("\n").gsub(/^/, '    ')
            ]
          else
            if invalid && (full_errors = record.errors.full_messages - ignore_errors).any?
              result = true
              error_ids << record.id
              errors |= full_errors
            end
          end

          print "#{model}#{" !" if errors.any?} #{(i += 1) * 100 / count}% #{Time.now.to_i - time}s\r"
        end

        if error_ids.any?
          puts
          puts "  Failing IDs: #{error_ids.inspect}"
          puts errors.map { |m| "  #{m}" }
        end
        if i != 0
          puts
        end
      end

      result
    end

    private

    def concrete_models
      @concrete_models ||= begin
        models = Dir["app/models/*.rb"].map { |f| File.basename(f).split('.').first.camelize.constantize }
        concrete = models.dup

        models.each do |model|
          if ! ActiveRecord::Base.in? model.ancestors
            concrete.delete model
          else
            concrete -= (model.ancestors - [ model ])
          end
        end

        concrete
      end
    end

    def symbolize(v)
      case v
      when Array then  v.map { |i| symbolize i }
      when Hash then   v.each.with_object({}) { |(k, v), h| h[symbolize k] = symbolize v }
      when String then v.to_sym
      else             v
      end
    end
  end
end
