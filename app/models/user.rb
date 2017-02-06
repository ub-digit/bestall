class User
  include ActiveModel::Model
  validates_presence_of :username
  validates_presence_of :first_name
  validates_presence_of :last_name
  attr_accessor :username, :first_name, :last_name

  def self.find_by_username username
    return self.new username: username
  end
end
