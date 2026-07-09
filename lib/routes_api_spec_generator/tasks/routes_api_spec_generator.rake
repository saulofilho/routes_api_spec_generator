# frozen_string_literal: true

require 'routes_api_spec_generator'
require 'rake'

namespace :routes_api_spec do
  desc 'Generate rswag request specs from Rails routes'
  task generate: :environment do
    result = RoutesApiSpecGenerator::Generator.new(
      rails_root: Rails.root,
      force: ENV['FORCE'] == 'true',
      dry_run: ENV['DRY_RUN'] == 'true'
    ).run

    result[:files].each do |file|
      case file[:status]
      when :written then puts "✓ #{file[:path]}"
      when :skipped then puts "○ #{file[:path]}"
      when :dry_run then puts "→ #{file[:path]}"
      end
    end

    puts "Done: #{result[:written]} written, #{result[:skipped]} skipped"
  end
end
