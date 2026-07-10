# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tmpdir'
require 'yaml'

RSpec.describe RoutesApiSpecGenerator::ConfigLoader do
  it 'returns empty config when file is missing' do
    loader = described_class.new(rails_root: FIXTURE_PATH)
    config = loader.load

    expect(config).to eq('defaults' => {}, 'endpoints' => {})
  end

  it 'loads yaml from rails root' do
    Dir.mktmpdir do |dir|
      config_dir = File.join(dir, 'config')
      FileUtils.mkdir_p(config_dir)
      File.write(
        File.join(config_dir, 'routes_api_spec_generator.yml'),
        { 'endpoints' => { 'api/v1/foo#index' => { 'tag' => 'Foo' } } }.to_yaml
      )

      config = described_class.new(rails_root: dir).load

      expect(config.dig('endpoints', 'api/v1/foo#index', 'tag')).to eq('Foo')
    end
  end
end

RSpec.describe RoutesApiSpecGenerator::ControllerInspector do
  let(:rails_root) { File.join(FIXTURE_PATH) }

  it 'infers insights template and tenant header' do
    hints = described_class.new(rails_root: rails_root).inspect('api/v1/insights', 'email_metrics')

    expect(hints[:template]).to eq('insights')
    expect(hints[:tenant_header]).to eq('X-Tenant-ID')
    expect(hints[:service_class]).to eq('Insights::EmailService')
    expect(hints[:channel]).to eq('email')
  end

  it 'uses general_metrics template for general_metrics action' do
    hints = described_class.new(rails_root: rails_root).inspect('api/v1/insights', 'general_metrics')

    expect(hints[:template]).to eq('general_metrics')
  end
end

RSpec.describe RoutesApiSpecGenerator do
  it 'has a version' do
    expect(RoutesApiSpecGenerator::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
