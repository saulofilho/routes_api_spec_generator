# frozen_string_literal: true

module RoutesApiSpecGenerator
  Endpoint = Struct.new(
    :verb,
    :path,
    :controller,
    :action,
    :template,
    :tag,
    :summary,
    :tenant_header,
    :service_class,
    :service_pattern,
    :spec_filename,
    :describe_name,
    :extra_params,
    :timezone,
    :channel,
    :resource_name,
    keyword_init: true
  ) do
    def route_key
      "#{controller}##{action}"
    end

    def insights?
      template == 'insights'
    end

    def channels?
      template == 'channels'
    end

    def big_numbers?
      template == 'big_numbers'
    end
  end
end
