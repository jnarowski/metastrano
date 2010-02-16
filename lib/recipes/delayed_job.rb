Capistrano::Configuration.instance(:must_exist).load do

  #----------------------------------------------------------------
  # DelayedJob
  # - Restart stops and starts because 
  # - I found the restart command to be buggy 
  #----------------------------------------------------------------
  
  namespace :delayed_job do 

    desc "Restart the delayed_job process"
    task :restart, :roles => :app do
      stop
      start
    end

    desc "Start the delayed_job process"
    task :start, :roles => :app do
      run "cd #{current_path}; #{sudo} #{rails_env} script/delayed_job start"
    end

    desc "Stop the delayed_job process"
    task :stop, :roles => :app do
      run "cd #{current_path}; #{sudo} #{rails_env} script/delayed_job stop"
    end

  end
  
end