# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'erb'
require 'yaml'

require_relative 'routes_api_spec_generator/version'
require_relative 'routes_api_spec_generator/endpoint'
require_relative 'routes_api_spec_generator/config_loader'
require_relative 'routes_api_spec_generator/route_collector'
require_relative 'routes_api_spec_generator/controller_inspector'
require_relative 'routes_api_spec_generator/generator'
require_relative 'routes_api_spec_generator/template_context'
require_relative 'routes_api_spec_generator/cli'

require_relative 'routes_api_spec_generator/railtie' if defined?(Rails::Railtie)

module RoutesApiSpecGenerator
  class Error < StandardError; end
end
