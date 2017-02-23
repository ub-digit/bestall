class Sublocation
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :location_id, :name_sv, :name_en

  def initialize id:, name_sv:, name_en:
    @id = id
    @location_id = id[0..1]
    @name_sv = name_sv
    @name_en = name_en
  end

  def self.all
    Rails.cache.fetch("sublocations", expires_in: 24.hours) do
      base_url = APP_CONFIG['koha']['base_url']
      user = APP_CONFIG['koha']['user']
      password = APP_CONFIG['koha']['password']

      url = "#{base_url}/auth_values/list?category=LOC&userid=#{user}&password=#{password}"
      response = RestClient.get url
      parse_xml(response)
    end
  end

  def self.find_all_by_location_id location_id
    all.select do |loc|
      location_id.to_s == loc.location_id.to_s
    end + [{id: "CART", location_id: location_id, name_sv: "Nyligen återlämnad", name_en: "Recently returned"}]
  end

  def self.parse_xml xml
    parsed_xml = Nokogiri::XML(xml).remove_namespaces!

    locs = []

    parsed_xml.search('//response/locs').each do |loc|
      id = loc.xpath('authorised_value').text
      next if id.blank?
      name_sv = loc.xpath('lib').text
      name_en = loc.xpath('lib').text

      locs << self.new(id: id, name_sv: name_sv, name_en: name_en)

    end

    return locs

  end

end
