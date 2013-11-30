app_name = 'headline-generator'
database_name_development = 'headline-generator'

namespace :heroku do

  namespace :db do

    desc "clones the heroku app DB, copies much faster than heroku db:pull, doesn't use taps"
    task :pull => ["db:drop","db:create","heroku:db:fetch", "heroku:db:import", "db:migrate"]

    task :fetch do
      a = ENV['app'] || app_name
      puts "Fetching database from #{a}"
      Bundler.with_clean_env {
        system %Q{
          #{"heroku pgbackups:capture -a #{a} --expire" unless ENV['no_capture']}
          #{"curl -o /tmp/headlines.dump `heroku pgbackups:url -a #{a}`" unless ENV['use_local_dump']}
        }
      }
    end

     task :import do
      a = ENV['app'] || app_name
      puts "Importing #{a} dump into development database."
      system %Q{
        pg_restore --verbose --clean --no-acl --no-owner -d headlines_development /tmp/headlines.dump
      }
    end

  end

end
