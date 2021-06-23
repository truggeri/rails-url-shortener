# https://auth0.com/docs/quickstart/backend/rails#define-a-secured-concern
module Secured
  extend ActiveSupport::Concern

  AUTHORIZATION_HEADER = 'Authorization'.freeze

  private

  def authenticate_request!
    return render_status(401) unless http_token.present?
    
    Auth0Token.verify(http_token)
  rescue JWT::VerificationError, JWT::DecodeError
    render_status(401)
  end

  def http_token
    return @http_token if defined?(@http_token)

    @http_token = begin
      request.headers[AUTHORIZATION_HEADER].split(' ').last if request.headers[AUTHORIZATION_HEADER].present?
    end
  end
end