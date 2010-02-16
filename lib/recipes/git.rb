Capistrano::Configuration.instance(:must_exist).load do

  #----------------------------------------------------------------
  # git 
  #----------------------------------------------------------------

  namespace :git do 
    desc "Creates a local git repo"
    task :init do
      # write the ignore files
      run_locally "sudo touch tmp/.gitignore log/.gitignore vendor/.gitignore"
      File.open('.gitignore', 'w') {|f| f.write(metastrano_load_template_file('gitignore')) }
      # init the git repo
      run_locally "git init"  
      run_locally "git add . "
      run_locally "git commit -a -m 'Initial Commit'"
      run_locally "git remote add origin git@#{domain}:#{application}.git"
      run_locally "git push origin master"
    end

    desc "Creates a remote git repo"
    task :init_remote do
      set(:repo_path) { Capistrano::CLI.ui.ask "Enter location of remote git repos" } unless exists?(:repo_path) 
      sudo "mkdir -p #{repo_path}/#{application}.git"
      sudo "git --bare --git-dir=#{repo_path}/#{application}.git init"
      sudo "chown #{scm}:#{scm} -R #{repo_path}/#{application}.git"
    end

    desc "Creates the remote git repo, then initializes the local repo and performs the first commit"
    task :setup do
      init_remote
      init
    end
  end
  
end