Capistrano::Configuration.instance(:must_exist).load do

  #----------------------------------------------------------------
  # Rake Tasks
  #----------------------------------------------------------------

  namespace :rake do 
    
    desc "Builds the most recent javascript and css files by running 'rake asset:packager:destroy_all' then 'rake asset:packager:build_all'"
    task :rebuild_assets, :roles => :db do
      run "cd #{current_path}; #{sudo} rake asset:packager:delete_all; #{sudo} rake asset:packager:build_all"
    end

    desc "Install gems for your rails app -- rake gems:install"
    task :gems_install, :roles => :app do
      run "cd #{current_path} && #{sudo} rake RAILS_ENV=production gems:install"
    end

  end
end