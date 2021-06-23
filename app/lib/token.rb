#
# Token - A simple wrapper around jwt gem
#
class Token
  ISSUER      = 'rails-url-shortener'.freeze
  SIGNING_ALG = 'HS256'.freeze

  def self.decode(token)
    JWT.decode(token, secret, true, { algorithm: SIGNING_ALG }).first
  rescue JWT::DecodeError
    nil
  end

  def self.encode(contents)
    return nil unless contents.is_a?(Hash)

    JWT.encode(payload(contents), secret, SIGNING_ALG, { typ: 'jwt' })
  end

  def self.payload(contents)
    { iat: Time.now.utc.to_i, iss: ISSUER }.merge(contents)
  end

  def self.secret
    @secret ||= ENV['JWT_SECRET']
  end
end
