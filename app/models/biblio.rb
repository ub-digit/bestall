class Biblio
  attr_accessor :id, :title, :author, :items

  include ActiveModel::Serialization
  include ActiveModel::Validations


  def can_be_borrowed

    @items.each do |item|
      return true if item.can_be_borrowed
    end

    return false
  end

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

    @items = []

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

    xml.search('//record/datafield[@tag="952"]').each do |item_data|
      @items << Item.new(biblio_id: self.id, xml: item_data.to_xml)
    end
  end

end
