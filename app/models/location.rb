class Location
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :name_sv, :name_en, :categories, :pickup_location_id, :is_disabled

  def initialize id:, name_sv:, name_en:, pickup_location_id:, categories:, is_disabled: false
    @id = id
    @name_sv = name_sv
    @name_en = name_en
    @pickup_location_id = pickup_location_id
    @categories = categories
    @is_disabled = is_disabled

  end

  def as_json options={}
    if options[:include_sublocations]
    super.merge({
        sublocations: Sublocation.find_all_by_location_id(id)
      })
    else
      super
    end
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

  def self.where record_type:, current_user:, current_item:, current_subscription:

    filtered_locations = self.all.filter_map do |location|
      next unless location.categories.include?("PICKUP")

      if location.categories.include?("CLOSED")
        location.is_disabled = true
        location.name_sv += " (stängt)"
        location.name_en += " (closed)"
      elsif location.categories.include?("NO_PICKUP")
        location.is_disabled = true
        location.name_sv += " (kan ej beställas hit)"
        location.name_en += " (can't be picked up here)"
      end
      location
    end

    return filtered_locations if !self.apply_additional_filter(record_type: record_type, current_item: current_item)
    entity = {}
    entity = current_item if current_item.present?
    entity = current_subscription if current_subscription.present?
    return filtered_locations if entity.blank?
    return filtered_locations if entity[:sublocation_open_pickup_loc]

    return filtered_locations if current_user.present? && ["SY", "FY", "FT"].include?(current_user[:categorycode])

    filtered_locations.each do |location|
      if location.id == entity[:pickup_location_id]
        location.is_disabled = true
        location.name_sv += " (kan ej beställas hit)"
        location.name_en += " (can't be picked up here)"
      end
    end

    return filtered_locations
end

  def self.apply_additional_filter record_type:, current_item:
    return true if record_type == "monograph" && current_item.present?
    return true if record_type == "serial" && current_item.present? && current_item[:can_be_ordered]
    return false
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
