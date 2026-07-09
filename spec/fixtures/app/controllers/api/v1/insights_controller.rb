# frozen_string_literal: true

class Api::V1::InsightsController < ApplicationController
  skip_before_action :validate_timezone, only: %i[general_metrics email_metrics]

  def general_metrics
    render json: metrics_payload(::Insights::GeneralMetrics)
  end

  def email_metrics
    render json: metrics_payload(::Insights::EmailService)
  end

  private

    def metrics_payload(service_class)
      service_class.new(tenant_id, period: period_params).call
    end
end
