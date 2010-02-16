require 'capistrano'
require 'capistrano/cli'

Capistrano::Configuration.instance(:must_exist).load do
  
  #----------------------------------------------------------------
  # configuration & defaults
  #----------------------------------------------------------------

  set :config_files, 'database.yml' 
  set :shared_children, %w(system log pids config)
  set :environment, 'production'
  set :repo_path, '/home/git'
  set :ruby_path, '/opt/ruby-enterprise-1.8.7-2009.10/bin/'
  set :user, 'capistrano'

  # version control
  set :scm, :git
  set :scm_username, :git
   
  # wordpress defaualts
  set :wordpress_version, '2.8.6'
  set :wordpress_symlinks, ["wp-content/avatars","wp-content/uploads","wp-content/cache"]
  set :wordpress_editable_dirs, ["wp-content/uploads"]
    
  #----------------------------------------------------------------
  # filters
  #----------------------------------------------------------------

  # after application setup
  after "deploy:setup" do
    db.mysql.setup if Capistrano::CLI.ui.agree("Do you want to create the database, user, and config/database.yml file?")  
    apache.create_vhost if Capistrano::CLI.ui.agree("Do you want to create the apache virtual host file?")  
  end
  
  #----------------------------------------------------------------
  # helper methods
  #----------------------------------------------------------------
  
  def metastrano_symlink(existing_path, symlinked_path)
    sudo "ln -nfs #{existing_path} #{symlinked_path}"
  end

  def metastrano_chmod(file, ownership = '0777')
    sudo "chmod #{ownership} -R #{file}"
  end
    
  def metastrano_load_template_file(file_name)
    local_file = "config/metastrano/#{file_name}"
    file_path = File.exists?(local_file) ? local_file : MetaStrano.path + "/templates/#{file_name}"
    File.open(file_path, 'r').read
  end

  def metastrano_load_erb_file(file_name)
    erb_template = ERB.new(metastrano_load_template_file("#{file_name}"))
    erb_template.result(binding)
  end
  
  def prepare_for_db_command
    set :db_name, "#{application}_#{environment}" unless exists?(:db_name)
    set(:db_admin_user) { Capistrano::CLI.ui.ask "Username with priviledged database access (to create db):" } unless exists?(:db_admin_user)
    set(:db_user) { Capistrano::CLI.ui.ask "Enter database username:" } unless exists?(:db_user)
    set(:db_pass) { Capistrano::CLI.password_prompt "Enter database password:" } unless exists?(:db_pass)
  end
end

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).each { |f| load f }

module MetaStrano
  def self.path
    File.dirname(__FILE__)
  end
end