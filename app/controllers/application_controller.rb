class ApplicationController < ActionController::API
  private

  def render_error(status)
    status = 500 unless status.in?(400..422)

    render(plain: I18n.t("errors.#{status}"), status: status)
  end
end
