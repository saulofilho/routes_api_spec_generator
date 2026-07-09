# frozen_string_literal: true

require_relative 'lib/routes_api_spec_generator/version'

Gem::Specification.new do |spec|
  spec.name          = 'routes_api_spec_generator'
  spec.version       = RoutesApiSpecGenerator::VERSION
  spec.authors       = ['Saulo Filho']
  spec.email         = ['saulofilho@users.noreply.github.com']

  spec.summary       = 'Gera request specs rswag a partir de rotas Rails'
  spec.description   = <<~DESC
    Ruby gem que lê rotas e controllers de uma API Rails e materializa
    request specs RSpec com rswag — alinhado ao fluxo spec → swagger
    (rswag:specs:swaggerize).
  DESC
  spec.homepage      = 'https://github.com/saulofilho/routes-api-spec-generator'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    files = `git ls-files -z 2>/dev/null`.split("\x0")
    if files.empty?
      Dir.glob('{lib,exe}/**/*', File::FNM_DOTMATCH) +
        %w[README.md LICENSE.txt CHANGELOG.md]
    else
      files.reject { |file| file.start_with?('spec/', '.github/') || file.end_with?('.gem') }
    end
  end

  spec.bindir        = 'exe'
  spec.executables   = ['routes-api-spec-generator']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 7.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
end
