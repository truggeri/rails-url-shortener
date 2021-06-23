class ApplicationController < ActionController::API
  AUTHORIZATION_HEADER = 'Authorization'.freeze

  private

  def authenticate!
    return render_status(401) unless request.headers[AUTHORIZATION_HEADER].present?

    token   = request.headers[AUTHORIZATION_HEADER].split.last
    payload = Token.decode(token)
    return render_status(401) unless authenticated?(payload)

    @authorized_for = { iat: payload['iat'], uuid: payload['uuid'] }
  end

  def authenticated?(payload)
    payload.present? && payload['iss'] == Token::ISSUER && payload['uuid'].present?
  end

  def render_status(status)
    status = 500 unless status.in?(400..422)

    render(plain: I18n.t("errors.#{status}"), status: status)
  end
end
