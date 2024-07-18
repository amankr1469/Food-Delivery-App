require 'jwt'

module JsonWebToken
  SECRET_KEY = ENV['Secret_Key']

  def self.encode(payload, exp = 7.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new body
  rescue
    nil
  end
end
