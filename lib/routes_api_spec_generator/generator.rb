# frozen_string_literal: true

require 'fileutils'

module RoutesApiSpecGenerator
  class Generator
    OUTPUT_DIR = 'spec/requests'

    def initialize(rails_root:, force: false, dry_run: false, namespace: '/api/v1')
      @rails_root = Pathname.new(rails_root)
      @force = force
      @dry_run = dry_run
      @namespace = namespace
      @config = ConfigLoader.new(rails_root: @rails_root).load
      @inspector = ControllerInspector.new(rails_root: @rails_root)
    end

    def run
      require_routes!
      routes = RouteCollector.new(routes: @routes, namespace_prefix: @namespace).collect
      endpoints = routes.map { |route| build_endpoint(route) }

      results = endpoints.map { |endpoint| write_endpoint(endpoint) }
      summary(results)
    end

    private

      def require_routes!
        require File.expand_path('config/environment', @rails_root)
        @routes = Rails.application.routes.routes
      end

      def build_endpoint(route)
        route_key = "#{route[:controller]}##{route[:action]}"
        config = (@config.dig('endpoints', route_key) || {}).transform_keys(&:to_s)
        hints = @inspector.inspect(route[:controller], route[:action])
        defaults = (@config['defaults'] || {}).transform_keys(&:to_s)

        template = config['template'] || hints[:template] || 'resource_index'
        action = route[:action]
        resource = route[:controller].split('/').last

        spec_filename = config['spec_filename'] || spec_filename_for(resource, action)
        describe_name = config['describe_name'] || route[:path].delete_prefix('/')

        Endpoint.new(
          verb: route[:verb],
          path: route[:path],
          controller: route[:controller],
          action: action,
          template: template,
          tag: config['tag'] || tag_for(resource, action),
          summary: config['summary'] || summary_for(resource, action),
          tenant_header: config['tenant_header'] || hints[:tenant_header] || 'Tenant-ID',
          service_class: config['service_class'] || hints[:service_class],
          service_pattern: config['service_pattern'] || hints[:service_pattern]&.to_s,
          spec_filename: spec_filename,
          describe_name: describe_name,
          extra_params: config['extra_params'] || extra_params_for(hints[:permitted_params]),
          timezone: config.fetch('timezone', !hints[:skip_timezone]),
          channel: config['channel'] || hints[:channel],
          resource_name: resource
        )
      end

      def spec_filename_for(resource, action)
        return "#{resource}_spec.rb" if action == 'index'

        "#{action}_spec.rb"
      end

      def tag_for(resource, action)
        return resource.singularize.camelize if action == 'index'

        'Insights'
      end

      def summary_for(resource, action)
        return "list #{resource.tr('_', ' ')}" if action == 'index'

        "#{action.tr('_', ' ')}"
      end

      def extra_params_for(permitted)
        Array(permitted).map(&:to_s) - %w[start_date end_date]
      end

      def write_endpoint(endpoint)
        relative = File.join(OUTPUT_DIR, endpoint.path.delete_prefix('/').gsub(%r{/[^/]+$}, '') || '',
                             endpoint.spec_filename).squeeze('/')
        # path like /api/v1/channels -> spec/requests/api/v1/channels_spec.rb
        output = @rails_root.join(OUTPUT_DIR, path_to_spec_dir(endpoint.path), endpoint.spec_filename)
        content = render(endpoint)

        if File.exist?(output) && !@force
          return { path: output, status: :skipped }
        end

        if @dry_run
          return { path: output, status: :dry_run, content: content }
        end

        FileUtils.mkdir_p(output.dirname)
        File.write(output, content)
        { path: output, status: :written }
      end

      def path_to_spec_dir(path)
        # /api/v1/channels -> api/v1
        # /api/v1/insights/email_metrics -> api/v1
        segments = path.delete_prefix('/').split('/')
        segments[0..1].join('/') # api/v1
      end

      def render(endpoint)
        template_file = template_path(endpoint.template)
        context = TemplateContext.new(endpoint)
        ERB.new(File.read(template_file), trim_mode: '-').result(context.instance_eval { binding })
      end

      def template_path(name)
        File.join(__dir__, 'templates', "#{name}.erb")
      end

      def summary(results)
        written = results.count { |r| r[:status] == :written }
        skipped = results.count { |r| r[:status] == :skipped }
        dry = results.count { |r| r[:status] == :dry_run }

        {
          written: written,
          skipped: skipped,
          dry_run: dry,
          files: results
        }
      end
  end
end
