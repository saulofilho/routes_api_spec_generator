# frozen_string_literal: true

module RoutesApiSpecGenerator
  class ConfigLoader
    DEFAULT_PATH = 'config/routes_api_spec_generator.yml'

    def initialize(rails_root:, config_path: nil)
      @rails_root = Pathname.new(rails_root)
      @config_path = config_path || @rails_root.join(DEFAULT_PATH)
    end

    def load
      return empty_config unless File.exist?(@config_path)

      YAML.safe_load(File.read(@config_path), aliases: true) || empty_config
    end

    private

      def empty_config
        { 'defaults' => {}, 'endpoints' => {} }
      end
  end
end
