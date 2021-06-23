# https://auth0.com/docs/quickstart/backend/rails#create-a-jsonwebtoken-class
require 'net/http'
require 'uri'

class Auth0Token
  def self.verify(token)
    JWT.decode(token, nil,
               true, # Verify the signature of this token
               algorithms: 'RS256',
               iss:        ENV['AUTH0_ISSUER'],
               verify_iss: true,
               aud:        ENV['AUTH0_AUDIENCE'],
               verify_aud: true) do |header|
      jwks_hash[header['kid']]
    end
  end

  def self.jwks_hash
    jwks_raw  = Net::HTTP.get URI("#{ENV['AUTH0_DOMAIN']}/.well-known/jwks.json")
    jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
    Hash[
      jwks_keys.map do |k|
        [
          k['kid'],
          OpenSSL::X509::Certificate.new(
            Base64.decode64(k['x5c'].first)
          ).public_key
        ]
      end
    ]
  end
end