# frozen_string_literal: true

module RoutesApiSpecGenerator
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'routes_api_spec_generator/tasks/routes_api_spec_generator.rake'
    end
  end
end
