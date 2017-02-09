class User
  include ActiveModel::Model
  validates_presence_of :username
#  validates_presence_of :first_name
#  validates_presence_of :last_name
  attr_accessor :username, :first_name, :last_name

  def self.find_by_username username
    return self.new(username: username)
  end

  # Password not used with CAS, left in place for later. Force auth will be true for CAS
  def authenticate(provided_password, force_authenticate=false)
    if force_authenticate
      token_object = AccessToken.generate_token(self)
      return token_object.token
    end

    return nil
#    auth_status = authenticate_local(provided_password)
#    auth_status
  end
end
