#
# Authentication
#   Provides a before_action to authenicate an action with Authorization header and jwt token
#
# ex:
#   include Authentication
#   before_action authenticate!
#
module Authentication
  extend ActiveSupport::Concern

  AUTHORIZATION_HEADER = 'Authorization'.freeze

  private

  def authenticate!
    return render_error(401) unless request.headers[AUTHORIZATION_HEADER].present?

    token   = request.headers[AUTHORIZATION_HEADER].split.last
    payload = Token.decode(token)
    return render_error(401) unless authenticated?(payload)

    @authorized_for = { iat: payload['iat'], uuid: payload['uuid'] }
  end

  def authenticated?(payload)
    payload.present? && payload['iss'] == Token::ISSUER && payload['uuid'].present?
  end
end
