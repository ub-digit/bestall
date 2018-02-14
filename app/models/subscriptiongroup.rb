class Subscriptiongroup
  attr_accessor :short_info, :subscriptions

  include ActiveModel::Serialization
  include ActiveModel::Validations

  def initialize short_info=[], subscriptions=[], location_id, biblio_id
    @biblio_id = biblio_id
    @id = location_id
    @location_id = location_id
    @short_info = short_info
    @subscriptions = subscriptions
  end
end
