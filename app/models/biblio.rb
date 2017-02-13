class Biblio
  attr_accessor :id, :title, :author, :can_be_ordered

  include ActiveModel::Serialization
  include ActiveModel::Validations

  def as_json options = {}
    super(except: ['xml'])
  end

  def initialize id, xml
    @id = id
    @xml = xml
    parse_xml
  end

  def self.find id
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    url = "#{base_url}/bib/#{id}?userid=#{user}&password=#{password}&items=1"
    response = RestClient.get url
    item = self.new id, response
    return item
  end

  def self.find_by_id id
    self.find id
  rescue => error
    return nil
  end

  def parse_xml
    xml = Nokogiri::XML(@xml).remove_namespaces!

    @author = xml.search('//record/datafield[@tag="100"]/subfield[@code="a"]').text

    if xml.search('//record/datafield[@tag="245"]/subfield[@code="a"]').text.present?
      @title = xml.search('//record/datafield[@tag="245"]/subfield[@code="a"]').text
    end
    if xml.search('//record/datafield[@tag="245"]/subfield[@code="b"]').text.present?
      @title = @title + ' ' + xml.search('//record/datafield[@tag="245"]/subfield[@code="b"]').text
    end
    if xml.search('//record/datafield[@tag="245"]/subfield[@code="p"]').text.present?
      @title = @title + ' ' + xml.search('//record/datafield[@tag="245"]/subfield[@code="p"]').text
    end

    if xml.search('//record/datafield[@tag="952"]/subfield[@code="y"]').text.present? && xml.search('//record/datafield[@tag="952"]/subfield[@code="y"]').text == '7'
      @can_be_ordered = false
    else
      @can_be_ordered = true
    end
  end

end
