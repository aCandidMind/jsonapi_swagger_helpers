module MyGem
  class Railtie < Rails::Engine
    rake_tasks do
      load 'tasks/swagger_diff.rake'
    end
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
  end
end
