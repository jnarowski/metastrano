Capistrano::Configuration.instance(:must_exist).load do

  #----------------------------------------------------------------
  # Apache Strategy
  #----------------------------------------------------------------

  namespace :apache do

    desc "Restarts Apache - sudo service httpd restart"
    task :restart, :roles => :app do
      run "#{sudo} service httpd restart"
    end

    desc "Creates the .conf file in the shared config directory, and creates a symlink to /etc/httpd/conf.d/application.conf"
    task :create_vhost do
      set(:server_name) { Capistrano::CLI.ui.ask "Enter ServerName" } unless exists?(:server_name) 
      vhost = metastrano_load_erb_file('apache.conf.erb')
        
      # uploads the above vhost file onto the server
      put vhost, "#{shared_path}/config/#{application}.conf"

      # removes any existing apache conf files
      sudo "rm -f /etc/httpd/conf.d/#{application}.conf"
      # move the application.conf file into your apache folder
      sudo "mv #{shared_path}/config/#{application}.conf /etc/httpd/conf.d/#{application}.conf"
      # make a symbolic link back to the shared config directory
      sudo "ln -nfs /etc/httpd/conf.d/#{application}.conf #{shared_path}/config/#{application}.conf"
    end

    desc "Chown files and folders for apache. This is used primarily for the wordpress uploads folders"
    task :restart, :roles => :app, :except => { :no_release => true } do
      apache.restart
    end
    
  end
  
end