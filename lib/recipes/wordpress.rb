Capistrano::Configuration.instance(:must_exist).load do

  #----------------------------------------------------------------
  # Wordpress 
  #
  #    create wordpress database and its user
  #    create the wp-config file
  #    symlink the wo-config file from its shared/config/wp-config file to current_path/blog/wp-config.php
  #    symlink any uploadable assets
  #
  #----------------------------------------------------------------
  
  namespace :wordpress do 
    desc "Setup the database"
    task :create_database do
      set :db_name, "#{application}_wordpress"
      prepare_for_db_command
      db.mysql.create_db
    end

    desc "Generate the config file"
    task :create_config_file do
      prepare_for_db_command
      set :db_name, "#{application}_wordpress"
      config_file = metastrano_load_erb_file("wordpress.#{wordpress_version}.php.erb")

      # uploads the above vhost file onto the server
      put config_file, "#{shared_path}/config/wp-config.php"

      # removes any existing wp-config files
      sudo "rm -f #{current_path}/blog/wp-config.php"
    end

    desc "Symlink the files for 'avatars', 'uploads' and 'cache'. Override this by setting :wordpress_symlinks"
    task :symlink_folders do
      wordpress_symlinks.each do |path|
        sudo "mkdir -p #{shared_path}/blog/#{path}"
        sudo "rm -f #{current_path}/public/blog/#{path}"
        metastrano_symlink("#{shared_path}/blog/#{path}", "#{current_path}/public/blog/#{path}")
      end
    end
    
    desc "Symlink the wp-config file from shared_path/config/wp-config to current_path/public/blog/wp-config"
    task :symlink_config_file do
      sudo "rm -f #{current_path}/public/blog/wp-config.php"
      metastrano_symlink("#{shared_path}/config/wp-config.php", "#{current_path}/public/blog/wp-config.php")
    end

    desc "Creates the database and its user, uploads the wp-config file, and symlinks the shared/config file with your current_path directory"
    task :setup do
      prepare_for_db_command
      create_database
      create_config_file
      create_symlinks
      make_folders_editable
    end
    
    desc "Symlinks the config files and image-uploads, avitar and cache folders"
    task :create_symlinks do
      symlink_config_file
      symlink_folders
    end

    desc "Makes the necessary folders editable such as the wp-content/uploads directory"
    task :make_folders_editable do
      wordpress_editable_dirs.each do |path|
        metastrano_chmod("#{shared_path}/blog/#{path}")
      end
    end
  end
  
end