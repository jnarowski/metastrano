Capistrano::Configuration.instance(:must_exist).load do
  namespace :db do

    desc "Runs rake db:seed to load in default seed data"
    task :seed, :roles => :db do
      run "cd #{current_path} && #{sudo} rake RAILS_ENV=production db:seed"
    end

    #----------------------------------------------------------------
    # MySQL Specific
    #----------------------------------------------------------------

    namespace :mysql do

      desc "Create MySQL database and user for this environment using prompted or preset values"
      task :setup, :roles => :db, :only => { :primary => true } do
        prepare_for_db_command # sets up the usernames and passwords
        create_db # creates the production database
        # create a test db if requested
        if Capistrano::CLI.ui.agree("Do you want to also create a test database? - #{application}_test - (Y/N)")
          set :db_name, "#{application}_test"
          create_db
        end
        create_yaml
      end 

      desc "Creates a MySQL database and grants the user permission"
      task :create_db do
        sql = <<-SQL
        CREATE DATABASE IF NOT EXISTS #{db_name};
        GRANT ALL PRIVILEGES ON #{db_name}.* TO #{db_user}@localhost IDENTIFIED BY '#{db_pass}';
        SQL

        run "mysql --user=#{db_admin_user} -p --execute=\"#{sql}\"" do |channel, stream, data|
          if data =~ /^Enter password:/
            pass = Capistrano::CLI.password_prompt "Enter database password for '#{db_admin_user}':"
            channel.send_data "#{pass}\n" 
          end
        end
      end

      desc "Create database.yml in shared path with settings for current stage and test env"
      task :create_yaml do      
        set(:db_user) { Capistrano::CLI.ui.ask "Enter #{environment} database username:" } unless exists?(:db_user) 
        set(:db_pass) { Capistrano::CLI.password_prompt "Enter #{environment} database password:" } unless exists?(:db_pass)
        # create the shared config folder if it doesn't already exist
        run "mkdir -p #{shared_path}/config"
        db_config = metastrano_load_erb_file('database.yml.erb')   
        # uploads the database.yml config file
        put db_config, "#{shared_path}/config/database.yml"
      end

      desc "Updates the symlink for database.yml file to the just deployed release."
      task :symlink, :except => { :no_release => true } do
        run "rm -f #{current_path}/config/database.yml"
        run "ln -nfs #{shared_path}/config/database.yml #{current_path}/config/database.yml"
      end

      desc "Loads remote production data into development database. Uses your local database.yml file for development and production passwords"
      task :load_remote_data, :roles => :db, :only => { :primary => true } do
        require 'yaml'

        # First lets get the remote database config file so that we can read in the database settings
        get("#{shared_path}/config/database.yml", "tmp/database.yml")

        # load the production settings within the database file
        remote_settings = YAML::load_file("tmp/database.yml")["production"]

        # we also need the local settings so that we can import the fresh database properly
        local_settings = YAML::load_file("config/database.yml")["development"]

        filename = "dump.#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.gz"
        on_rollback { delete "/tmp/#{filename}" }

        run "mysqldump -u #{remote_settings['username']} --password=#{remote_settings['password']} #{remote_settings['database']} | gzip > /tmp/#{filename}" do |channel, stream, data|
          puts data
        end

        get "/tmp/#{filename}", "/tmp/#{filename}"
        run_locally "gunzip -c /tmp/#{filename} | mysql -u #{local_settings['username']} #{local_settings['password']} #{local_settings['database']} && rm -f gunzip #{filename} && rm -f tmp/database.yml"
      end         
    end
  end
end