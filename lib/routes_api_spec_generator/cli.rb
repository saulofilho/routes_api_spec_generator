# frozen_string_literal: true

require 'optparse'

module RoutesApiSpecGenerator
  class CLI
    def self.start(argv = ARGV)
      new.run(argv)
    end

    def run(argv)
      options = {
        force: false,
        dry_run: false,
        namespace: '/api/v1'
      }

      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: routes-api-spec-generator generate [options]'

        opts.on('--root PATH', 'Rails app root (default: Dir.pwd)') { |v| options[:root] = v }
        opts.on('--force', 'Overwrite existing spec files') { options[:force] = true }
        opts.on('--dry-run', 'Print paths without writing files') { options[:dry_run] = true }
        opts.on('--namespace PATH', 'Route prefix (default: /api/v1)') { |v| options[:namespace] = v }
        opts.on('-h', '--help', 'Show help') { puts opts; exit }
      end

      parser.parse!(argv)
      command = argv.first || 'generate'

      case command
      when 'generate'
        generate!(options)
      else
        warn "Unknown command: #{command}"
        puts parser
        exit 1
      end
    end

    private

      def generate!(options)
        root = options[:root] || Dir.pwd
        generator = Generator.new(
          rails_root: root,
          force: options[:force],
          dry_run: options[:dry_run],
          namespace: options[:namespace]
        )
        result = generator.run
        report(result)
      end

      def report(result)
        result[:files].each do |file|
          case file[:status]
          when :written
            puts "✓ wrote #{file[:path]}"
          when :skipped
            puts "○ skipped #{file[:path]} (exists; use --force)"
          when :dry_run
            puts "→ would write #{file[:path]}"
          end
        end

        puts "\nDone: #{result[:written]} written, #{result[:skipped]} skipped, #{result[:dry_run]} dry-run"
      end
  end
end
