class Subscription
  attr_accessor :id, :biblio_id, :sublocation_id, :call_number, :public_note

  include ActiveModel::Serialization
  include ActiveModel::Validations

  def initialize id, biblio_id, sublocation_id, call_number, public_note
    @id = id
    @biblio_id = biblio_id
    @sublocation_id = sublocation_id
    @call_number = call_number
    @public_note = public_note
  end

  def self.find_by_biblio_id biblio_id
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    url = "#{base_url}/subscriptions/list?biblionumber=#{biblio_id}&userid=#{user}&password=#{password}"
    response = RestClient.get url

    xml = Subscription.process_xml(response)
    subscriptions = Array.new

    xml.search('//response/subscriptions').each do |subscription|
      id = Subscription.parse_id subscription
      sublocation_id = Subscription.parse_sublocation_id subscription
      call_number = Subscription.parse_call_number subscription
      public_note = Subscription.parse_public_note subscription
      subscriptions << self.new(id, biblio_id, sublocation_id, call_number, public_note)
    end

    return subscriptions
  end

  def self.process_xml xml
    return xml if xml.kind_of?(Nokogiri::XML::Document)
    Nokogiri::XML(xml).remove_namespaces!
  end

  def self.parse_id xml
    xml.search('subscriptionid').text
  end

  def self.parse_sublocation_id xml
    xml.search('location').text
  end

  def self.parse_call_number xml
    xml.search('callnumber').text
  end

  def self.parse_public_note xml
    xml.search('notes').text
  end
end
