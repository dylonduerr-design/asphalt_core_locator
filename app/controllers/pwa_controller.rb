# frozen_string_literal: true

class PwaController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:service_worker]

  def manifest
    render template: "pwa/manifest", formats: [:json]
  end

  def service_worker
    render template: "pwa/service_worker", formats: [:js], content_type: "text/javascript"
  end
end
