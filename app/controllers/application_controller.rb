class ApplicationController < ActionController::API
  private

  def render_status(status)
    status = 500 unless status.in?(400..422)

    render(json: { errors: [I18n.t("errors.#{status}")] }, status: status)
  end
end
