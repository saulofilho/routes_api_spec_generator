# frozen_string_literal: true

module RoutesApiSpecGenerator
  class TemplateContext
    attr_reader :endpoint

    def initialize(endpoint)
      @endpoint = endpoint
    end
  end
end
