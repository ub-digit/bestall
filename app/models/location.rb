class Location
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :name_sv, :name_en, :categories, :pickup_location_id

  def initialize id:, name_sv:, name_en:, pickup_location_id:, categories:
    @id = id
    @name_sv = name_sv
    @name_en = name_en
    @pickup_location_id = pickup_location_id
    @categories = categories

  end

  def as_json options={}
    super.merge({
      sublocations: Sublocation.find_all_by_location_id(id)
    })
  end

  def self.all
    Rails.cache.fetch("locations", expires_in: 24.hours) do
      base_url = APP_CONFIG['koha']['base_url']
      user =  APP_CONFIG['koha']['user']
      password =  APP_CONFIG['koha']['password']

      url = "#{base_url}/branches/list?login_userid=#{user}&login_password=#{password}"
      response = RestClient.get url
      parse_xml(APP_CONFIG['locations'], response).sort_by do |location|
        location.id.to_i
      end
    end
  end

  def self.find_by_id id
    res = all.find do |loc|
      id.to_s == loc.id.to_s
    end
    return self.new(id: "1", name_sv: "", name_en: "", pickup_location_id: "", categories: []) if res.blank?
    res
  end

  def self.parse_xml locations, xml
    parsed_xml = Nokogiri::XML(xml).remove_namespaces!
    branches = []

    parsed_xml.search('//response/branches').each do |branch|
      id = branch.xpath('branchcode').text
      next if id.blank?
      location = locations.select{|l|l["id"].eql?(id)}.first
      if location.present? # Normal case
        name_sv = location["name_sv"] ? location["name_sv"] : ""
        name_en = location["name_en"] ? location["name_en"] : ""
        pickup_location_id = location["force_pickup_location_id"] ? location["force_pickup_location_id"] : id
      else # If entry is missing in local configuration, use values from Koha
        name_sv = branch.xpath('branchname').text
        name_en = branch.xpath('branchname').text
        pickup_location_id = id
      end
      categories = branch.xpath('categories').map(&:text)

      branches << self.new(id: id, name_sv: name_sv, name_en: name_en, pickup_location_id: pickup_location_id, categories: categories)

    end

    return branches

  end


end
