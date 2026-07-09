# frozen_string_literal: true

module RoutesApiSpecGenerator
  class RouteCollector
    def initialize(routes:, namespace_prefix: '/api/v1', verbs: %w[GET])
      @routes = routes
      @namespace_prefix = namespace_prefix
      @verbs = verbs.map(&:upcase)
    end

    def collect
      @routes.filter_map do |route|
        next unless matching_route?(route)

        verb = primary_verb(route)
        next unless @verbs.include?(verb)

        {
          verb: verb,
          path: route.path.spec.to_s.gsub('(.:format)', ''),
          controller: route.defaults[:controller],
          action: route.defaults[:action].to_s
        }
      end.uniq { |r| [r[:path], r[:verb], r[:action]] }
    end

    private

      def matching_route?(route)
        path = route.path.spec.to_s
        return false unless path.start_with?(@namespace_prefix)
        return false if route.defaults[:controller].blank?

        route.defaults[:controller].exclude?('rails/')
      end

      def primary_verb(route)
        verb = route.verb
        return 'GET' if verb.blank?

        case verb
        when String
          verb.upcase
        when Regexp
          verb.source.gsub(/[\^\$\(\)]/, '').split('|').first.to_s.upcase
        else
          'GET'
        end
      end
  end
end
