class Location
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :name_sv, :name_en, :categories

  def initialize id:, name_sv:, name_en:, categories:
    @id = id
    @name_sv = name_sv
    @name_en = name_en
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

      url = "#{base_url}/branches/list?userid=#{user}&password=#{password}"
      response = RestClient.get url
      parse_xml(response).sort_by do |location|
        location.id.to_i
      end
    end
  end

  def self.find_by_id id
    res = all.find do |loc|
      id.to_s == loc.id.to_s
    end
    return self.new(id: "1", name_sv: "", name_en: "", categories: []) if res.blank?
    res
  end

  def self.parse_xml xml
    parsed_xml = Nokogiri::XML(xml).remove_namespaces!

    branches = []
    branches_en =  {"40" => "Biomedical Library", "42" => "Social Sciences Library", "43" => "Botanical and Environmental Library", "44" => "Humanities Library", "46" => "Department Library", "47" => "Education Library", "48" => "Economics Library", "49" => "Earth Sciences and Conservation Library", "50" => "Learning Centre Campus Linné", "60" => "Art Library", "62" => "Music and Drama Library", "66" => "Learning Centre Hälsovetarbacken"}

    parsed_xml.search('//response/branches').each do |branch|
      id = branch.xpath('branchcode').text
      next if id.blank?
      name_sv = branch.xpath('branchname').text
      name_en = branches_en[id]
      categories = branch.xpath('categories').map(&:text)

      branches << self.new(id: id, name_sv: name_sv, name_en: name_en, categories: categories)

    end

    return branches

  end


end
