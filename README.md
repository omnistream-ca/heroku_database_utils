# HerokuDatabaseUtils

Useful rake tasks for Rails applications that are deployed on Heroku.
It allows:

* Replicating Heroku database backups into the development environment.
* Sanitizing the contents of these replicas.
* Verifying that newer migrations run correctly against the replicas.
* Run model validations against all records in the replica.

## Installation

Add this line to your application's Gemfile:

    gem 'heroku_database_utils'

And then execute:

    $ bundle

## Usage

Copy heroku_database_utils.yml into your application's config/ directory and
modify to suit your schema.

The following rake tasks are available:

    rake hdb:development:backup

Creates a backup of the current development database into development.dump.

    rake hdb:development:restore

Restores development.dump and deletes it.

    rake hdb:development:sanitize

Sanitizes the contents of the development database.

    rake hdb:development:validate

Loads all database records (that have a model in app/models/) and checks if
they are valid. Outputs some detail about which record IDs were invalid and
related error messages.

    rake hdb:development:continue_validation

Continues a Heroku DB replica validation (see below) run at the start of the
validation stage, rather than recreating the replica. Use this after adding
migrations and/or updating models that attempt to fix migration/validation
errors from a previously incomplete validation run.

For each configured Heroku application, the following rake tasks are
available:

    rake hdb:<instance>:load

Loads the latest backup from the Heroku application into the development
environment and sanitizes its contents.

    rake hdb:<instance>:validate

Loads the latest backup from the Heroku application into the development
environment, sanitizes its contents, run migrations and then runs model
validations. If migrations of validations fail, then you can use the
continue_validation task to re-run those parts without having to reload the
backup from Heroku.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
