# routes_api_spec_generator

[![Gem Version](https://badge.fury.io/rb/routes_api_spec_generator.svg)](https://badge.fury.io/rb/routes_api_spec_generator)

**Site:** [saulofilho.github.io/routes-api-spec-generator](https://saulofilho.github.io/routes-api-spec-generator/)

Gera **request specs RSpec com rswag** a partir de **rotas Rails** e inspeção de controllers.

Ferramenta open source para times que usam o fluxo **spec → swagger** (`rake rswag:specs:swaggerize`) e querem reduzir o boilerplate ao cobrir novos endpoints.

## O que ela faz

- Lê rotas Rails (ex.: `/api/v1/*`)
- Inspeciona controllers para inferir services, headers de tenant e parâmetros
- Aplica overrides opcionais via `config/routes_api_spec_generator.yml`
- Materializa arquivos em `spec/requests/**/_spec.rb` via templates ERB

## O que ela NÃO faz

- Gerar specs a partir do Swagger (fluxo circular no rswag)
- Substituir mocks ou schemas detalhados específicos do seu domínio
- Rodar testes ou publicar o contrato OpenAPI automaticamente

## Instalação

```bash
gem install routes_api_spec_generator
```

Ou no `Gemfile` de um app Rails:

```ruby
group :development, :test do
  gem 'routes_api_spec_generator'
end
```

## Uso via Rake (app Rails)

```bash
bundle exec rake routes_api_spec:generate
FORCE=true bundle exec rake routes_api_spec:generate   # sobrescreve existentes
DRY_RUN=true bundle exec rake routes_api_spec:generate # apenas lista
```

## Uso via CLI

```bash
routes-api-spec-generator generate
routes-api-spec-generator generate --force --root /path/to/rails/app
routes-api-spec-generator generate --dry-run --namespace /api/v2
```

### Opções

| Flag | Descrição |
|------|-----------|
| `--root PATH` | Raiz do app Rails (default: diretório atual) |
| `--force` | Sobrescrever specs existentes |
| `--dry-run` | Listar arquivos sem gravar |
| `--namespace PATH` | Prefixo de rotas (default: `/api/v1`) |

## Configuração

Opcional: `config/routes_api_spec_generator.yml`

```yaml
defaults:
  namespace: /api/v1

endpoints:
  api/v1/insights#email_metrics:
    template: insights
    tag: Insights
    summary: email origin metrics
    tenant_header: X-Tenant-ID
    service_class: Insights::EmailService
    channel: email
```

Chaves em `endpoints` seguem `controller#action` (ex.: `api/v1/channels#index`).

## Uso programático

```ruby
require 'routes_api_spec_generator'

result = RoutesApiSpecGenerator::Generator.new(
  rails_root: Rails.root,
  force: false
).run

puts "Gerados: #{result[:written]}, ignorados: #{result[:skipped]}"
```

## Publicar no RubyGems.org

```bash
bundle install
bundle exec rspec
gem build routes_api_spec_generator.gemspec
gem push routes_api_spec_generator-0.1.1.gem
```

> Requer conta no [RubyGems.org](https://rubygems.org) e MFA habilitado.

## Desenvolvimento

```bash
git clone https://github.com/saulofilho/routes-api-spec-generator.git
cd routes-api-spec-generator
bundle install
bundle exec rspec
bundle exec rake
```

## Fluxo recomendado

```
routes.rb + controllers  →  routes_api_spec_generator  →  spec/requests/**/*
                                                              ↓
                                                         rspec (green)
                                                              ↓
                                              rake rswag:specs:swaggerize
```

## Licença

MIT — veja [LICENSE.txt](LICENSE.txt).
