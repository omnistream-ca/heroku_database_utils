# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'heroku_database_utils/version'

Gem::Specification.new do |spec|
  spec.name          = "heroku_database_utils"
  spec.version       = HerokuDatabaseUtils::VERSION
  spec.authors       = ["Mark Thorn"]
  spec.email         = ["mark@warewolf.ca"]
  spec.description   = %q{Makes it easier to reproduce bugs from production and test new migrations against production data.}
  spec.summary       = %q{Rake tasks for replicating, sanitizing and validating heroku databases}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "activesupport", ">= 3.2.0"
  spec.add_dependency "activerecord", ">= 3.2.0"
end
