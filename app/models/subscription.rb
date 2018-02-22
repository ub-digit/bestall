class Subscription
  attr_accessor :id, :biblio_id, :sublocation_id, :call_number, :public_note, :location_id

  include ActiveModel::Serialization
  include ActiveModel::Validations

  def initialize id, biblio_id, sublocation_id, call_number, public_note, location_id
    @id = id
    @biblio_id = biblio_id
    @sublocation_id = sublocation_id
    @call_number = call_number
    @public_note = public_note
    @location_id = location_id
    @subscriptiongroup_id = location_id
    sublocation = Sublocation.find_by_id(sublocation_id)
    @sublocation_name_sv = sublocation.name_sv
    @sublocation_name_en = sublocation.name_en
    location = Location.find_by_id(sublocation.location_id)
    @location_name_sv = location.name_sv
    @location_name_en = location.name_en

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
      public_note = Subscription.parse_public_note subscription
      sublocation_id = Subscription.parse_sublocation_id subscription
      location_id = Subscription.parse_location_id subscription
      if public_note.present? && sublocation_id.present?
        id = Subscription.parse_id subscription
        call_number = Subscription.parse_call_number subscription
        subscriptions << self.new(id, biblio_id, sublocation_id, call_number, public_note, location_id)
      end
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

  def self.parse_location_id xml
    xml.search('branchcode').text
  end

  def self.parse_sublocation_id xml
    xml.search('location').text
  end

  def self.parse_call_number xml
    xml.search('callnumber').text
  end

  def self.parse_public_note xml
    xml.search('recievedlist').text.gsub(%r~<br\s*\/?>~, "\n")
  end
end
