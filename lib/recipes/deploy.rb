Capistrano::Configuration.instance(:must_exist).load do

  #----------------------------------------------------------------
  # Deploy Strategy
  # - this assumes you are using passanger
  #----------------------------------------------------------------
  
  namespace :deploy do
    desc "Restarting mod_rails with restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
      apache.restart
    end

    desc "Update the crontab file if you are using the whenever GEM"
    task :update_crontab, :roles => :db do
      run "cd #{current_path} && #{sudo} whenever --update-crontab #{application}"
    end

    [:start, :stop].each do |t|
      desc "#{t} task is a no-op with mod_rails"
      task t, :roles => :app do ; end
    end
  end
end