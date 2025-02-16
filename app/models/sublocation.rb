class Sublocation
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :location_id, :name_sv, :name_en, :is_open_loc, :is_open_pickup_loc, :is_paging_loc, :is_kursbok_loc, :location

  def initialize id:, name_sv:, name_en:, is_open_loc:, is_open_pickup_loc:, is_paging_loc:, is_kursbok_loc:
    @id = id
    @location_id = id[0..1]
    @name_sv = name_sv
    @name_en = name_en
    @is_open_loc = is_open_loc
    @is_paging_loc = is_paging_loc
    @is_open_pickup_loc = is_open_pickup_loc
    @is_kursbok_loc = is_kursbok_loc
  end



  def self.all
    Rails.cache.fetch("sublocations", expires_in: 24.hours) do
      base_url = APP_CONFIG['koha']['base_url']
      user = APP_CONFIG['koha']['user']
      password = APP_CONFIG['koha']['password']

      url = "#{base_url}/sublocations/list?login_userid=#{user}&login_password=#{password}"
      response = RestClient.get url
      parse_xml(response)
    end
  end

  def self.find_by_id id
    res = all.find do |loc|
      id.to_s == loc.id.to_s
    end
    return self.new(id: "1", name_sv: "", name_en: "", is_open_loc: false, is_open_pickup_loc: false, is_paging_loc: false, is_kursbok_loc: false) if res.blank?
    res
  end

  def self.find_all_by_location_id location_id
    all.select do |loc|
      location_id.to_s == loc.location_id.to_s
    end
  end

  def self.parse_xml xml
    parsed_xml = Nokogiri::XML(xml).remove_namespaces!

    locs = []

    parsed_xml.search('//response/value').each do |loc|
      id = loc.xpath('authorised_value').text
      next if id.blank?
      name_sv = loc.xpath('lib_opac').text
      name_en = loc.xpath('lib_opac').text

      is_open_pickup_loc = loc.xpath('open_pickup_loc').text
      is_open_loc = loc.xpath('open_loc').text
      is_paging_loc = loc.xpath('paging_loc').text
      is_kursbok_loc = loc.xpath('kursbok_loc').text

      locs << self.new(id: id, name_sv: name_sv, name_en: name_en, is_open_loc: (is_open_loc || is_open_pickup_loc), is_open_pickup_loc: is_open_pickup_loc, is_paging_loc: is_paging_loc, is_kursbok_loc: is_kursbok_loc)
    end

    return locs

  end

end
