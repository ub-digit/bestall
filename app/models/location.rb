class Location
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :name_sv, :name_en

  def initialize id:, name_sv:, name_en:
    @id = id
    @name_sv = name_sv
    @name_en = name_en

  end

  def as_json options={}

    super.merge({
      sublocations: Sublocation.find_all_by_location_id(id)
    })
  end

  def self.all
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    url = "#{base_url}/branches/list?userid=#{user}&password=#{password}"
    response = RestClient.get url
    parse_xml(response).sort_by do |location|
      location.id.to_i
    end
  end

  def self.parse_xml xml
    parsed_xml = Nokogiri::XML(xml).remove_namespaces!

    branches = []

    parsed_xml.search('//response/branches').each do |branch|
      id = branch.xpath('branchcode').text
      next if id.blank?
      name_sv = branch.xpath('branchname').text
      name_en = branch.xpath('branchname').text

      branches << self.new(id: id, name_sv: name_sv, name_en: name_en)

    end

    return branches

  end


end
