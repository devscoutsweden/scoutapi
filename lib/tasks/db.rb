namespace :db do
  desc 'Run DB migrations'
  task :migrate => :app do
   require 'sequel/extensions/migration'

   Sequel::Migrator.apply(Scoutapi::App.database, 'db/migrations')
  end

  desc 'Rollback migration'
  task :rollback => :app do
    require 'sequel/extensions/migration'
    database = Scoutapi::App.database

    version  = (row = database[:schema_info].first) ? row[:version] : nil
    Sequel::Migrator.apply(database, 'db/migrations', version - 1)
  end

  desc 'Dump the database schema'
  task :dump => :app do
    database = Scoutapi::App.database

    `sequel -d #{database.url} > db/schema.rb`
    `pg_dump --schema-only #{database.url} > db/schema.sql`
  end
end