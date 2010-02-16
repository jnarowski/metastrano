Capistrano::Configuration.instance(:must_exist).load do

  #----------------------------------------------------------------
  # Setup 
  #----------------------------------------------------------------
  
  namespace :setup do 
    desc "Copies the database.yml file, the apache.conf file, and the gitignore files to config/metastrano/files"
    task :copy_templates do
      run_locally "mkdir config/metastrano"      
      run_locally "cp #{MetaStrano.path}/templates/apache.conf.erb config/metastrano/apache.conf.erb"
      run_locally "cp #{MetaStrano.path}/templates/database.yml.erb config/metastrano/database.yml.erb"
      run_locally "cp #{MetaStrano.path}/templates/gitignore.erb config/metastrano/gitignore.erb"
      run_locally "cp #{MetaStrano.path}/templates/wordpress.#{wordpress_version}.php.erb config/metastrano/wordpress.#{wordpress_version}.php.erb"
    end
  end
  
end