# desc "Explaining what the task does"
# task :bloget do
#   # Task goes here
# end

namespace :bloget do
  
  task :load_rails do
    unless Kernel.const_defined?('RAILS_ROOT')
      Kernel.const_set('RAILS_ROOT', File.join(File.dirname(__FILE__), '..', '..', '..'))
    end

    if (File.exists?(RAILS_ROOT) && File.exists?(File.join(RAILS_ROOT, 'app')))
      require "#{RAILS_ROOT}/config/boot"
      require "#{RAILS_ROOT}/config/environment"
      require 'rails_generator'
      require 'rails_generator/scripts/generate'
    end    
  end

  desc "Installs required and recommended plugins for Bloget."
  task :install_friends do
    Dir.chdir(RAILS_ROOT) do
      puts `ruby script/plugin install git://github.com/technoweenie/restful-authentication.git`
      puts `ruby script/plugin install git://github.com/mislav/will_paginate.git`
    end
  end
  
  desc "Sets up a Rails app with the recommended infrastructure for Bloget."
  task :setup_app => [:load_rails, :install_friends] do
    Rails::Generator::Scripts::Generate.new.run(['authenticated', 'user', 'sessions'])    
    Rails::Generator::Scripts::Generate.new.run(['bloget_app'])
  end
  
  desc "Installs Bloget"
  task :install => :load_rails do
    Rails::Generator::Scripts::Generate.new.run(['bloget'])
  end
  
end

