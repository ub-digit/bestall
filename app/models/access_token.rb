class AccessToken < ApplicationRecord

  validate :user_reference
  DEFAULT_TOKEN_EXPIRE = 1.day

  # Call validate_token on itself for convenience
  def validated?
    AccessToken.validate_token(token)
  end

  def user
    return User.find_by_username(username)
  end

  # Clear all tokens that have expired
  def self.clear_expired_tokens
    AccessToken.where("token_expire < ?", Time.now).destroy_all
  end

  # First clear all invalid tokens. Then look for our provided token.
  # If we find one, we know it is valid, and therefor update its validity
  # further into the future
  def self.validate_token(provided_token)
    AccessToken.clear_expired_tokens
    token_object = AccessToken.find_by_token(provided_token)
    return false if !token_object
    token_object.update_attribute(:token_expire, Time.now + DEFAULT_TOKEN_EXPIRE)
    true
  end

  # Generate a random token
  def self.generate_token(user)
    return nil if !user
    token_hash = SecureRandom.hex
    token_hash.force_encoding('utf-8')
    token_data = {
      token: token_hash,
      token_expire: Time.now + DEFAULT_TOKEN_EXPIRE,
      username: user.username,
      user_id: user.id
    }
    AccessToken.create(token_data)
  end

  def user_reference
    if username.blank?
      @errors.add(:username, :blank_when_user_id_blank)
    end
  end
end
