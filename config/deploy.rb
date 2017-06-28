require 'mina/rails'
require 'mina/git'
require 'mina/rvm'    # for rvm support. (https://rvm.io)
require 'yaml'

set :rvm_use_path, '/usr/local/rvm/scripts/rvm'

# configuring
def load_config server
  settings = YAML.load(File.open("config/deploy_conf.yml"))
  puts "———-> configuring #{server} server"
  set :user, settings[server]['user']
  set :domain, settings[server]['domain']
  set :deploy_to, settings[server]['deploy_to']
  set :repository, settings[server]['repository']
  set :branch, settings[server]['branch']
  set :rails_env, settings[server]['rails_env']
end

YAML.load(File.open('config/deploy_conf.yml')).keys.each do |server|
  desc %{Set up #{server} for deployment}
  task "setup_#{server}" => :environment do
    load_config(server)
    invoke :setup
  end
  desc %{deploy to #{server} server}
  task "d_#{server}" => :environment do
    load_config(server)
    invoke :deploy
  end

  desc %{start to #{server} server}
  task "s_#{server}" => :environment do
    load_config(server)
    invoke :start
  end

  desc %{restart to #{server} server}
  task "r_#{server}" => :environment do
    load_config(server)
    invoke :restart
  end

  desc %{stop to #{server} server}
  task "stop_#{server}" => :environment do
    load_config(server)
    invoke :stop
  end

end

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push(
                                              'public/data',
                                              )
set :shared_files, fetch(:shared_files, []).push('config/database.yml',
                                                 'config/deploy_conf.yml',
                                                )

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', 'ruby-2.4.1@rails4'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup => :environment do
  command %[mkdir -p "#{fetch(:deploy_to)}/shared/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/log"]

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/config"]

  command %[touch "#{fetch(:deploy_to)}/shared/config/database.yml"]
  command  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]

    # sidekiq needs a place to store its pid file and log file
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/pids/")
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/log/")

end

desc 'Starts the application'
task :start => :environment do
  command "cd #{fetch(:deploy_to)}/current ; bundle exec unicorn_rails -E production -D -c config/unicorn.rb"
  command  %[echo "-----> deploy start ok."]
end

desc 'Stops the application'
task :stop => :environment do
  command %[kill `cat #{fetch(:deploy_to)}/current/tmp/pids/unicorn.pid`]
  command  %[echo "-----> deploy stop ok."]
end

task :restart => :environment do
  report_time do
    invoke :stop
    # sleep 3
    invoke :start
  end
  command  %[echo "-----> deployer restart ok."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_create'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
