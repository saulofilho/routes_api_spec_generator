# frozen_string_literal: true

module RoutesApiSpecGenerator
  class ControllerInspector
    SERVICE_PATTERNS = {
      /metrics_payload\(::Insights::(\w+)\)/ => :insights,
      /::Channels::ResultsAggregatorService/ => :aggregator,
      /::Channels::StatsFinder/ => :stats_finder
    }.freeze

    def initialize(rails_root:)
      @rails_root = rails_root
    end

    def inspect(controller_path, action)
      file = controller_file(controller_path)
      return {} unless file && File.exist?(file)

      source = File.read(file)
      hints = {
        permitted_params: extract_permit(source),
        skip_timezone: source.include?('skip_before_action :validate_timezone'),
        service_class: extract_service_for_action(source, action),
        service_pattern: nil
      }

      hints[:service_pattern] = infer_service_pattern(hints[:service_class], source)
      hints[:template] = infer_template(controller_path, action, hints, source)
      hints[:tenant_header] = controller_path.include?('insights') ? 'X-Tenant-ID' : 'Tenant-ID'
      hints[:channel] = infer_channel(action)
      hints
    end

    private

      def controller_file(controller_path)
        @rails_root.join('app/controllers', "#{controller_path}_controller.rb")
      end

      def extract_permit(source)
        match = source.match(/params\.permit\(([^)]+)\)/m)
        return [] unless match

        match[1].scan(/:(\w+)/).flatten.map(&:to_sym)
      end

      def extract_service_for_action(source, action)
        match = source.match(/def #{action}\s*\n.*?metrics_payload\(::Insights::(\w+)\)/m)
        return "Insights::#{match[1]}" if match

        return 'Channels::ResultsAggregatorService' if source.include?('ResultsAggregatorService')
        return 'Channels::StatsFinder' if source.include?('StatsFinder')

        nil
      end

      def infer_service_pattern(service_class, source)
        return :insights if service_class&.start_with?('Insights::')
        return :aggregator if service_class == 'Channels::ResultsAggregatorService'
        return :stats_finder if service_class == 'Channels::StatsFinder' || source.include?('StatsFinder')

        nil
      end

      def infer_channel(action)
        return 'email' if action.include?('email')
        return 'sms' if action.include?('sms')
        return 'whatsapp' if action.include?('whatsapp')

        nil
      end

      def infer_template(_controller_path, action, hints, _source)
        return 'general_metrics' if action == 'general_metrics'
        return 'insights' if hints[:service_pattern] == :insights
        return 'big_numbers' if hints[:service_pattern] == :aggregator
        return 'channels' if hints[:service_pattern] == :stats_finder

        action == 'index' ? 'resource_index' : 'insights'
      end
  end
end
