class Item
  attr_accessor :id, :biblio_id, :item_type

  include ActiveModel::Serialization
  include ActiveModel::Validations

  def initialize biblio_id:, xml:
    @biblio_id = biblio_id
    parse_xml(xml)
  end

  def can_be_ordered
    # TODO Extend with more rules
    @item_type != '7'
  end

  def parse_xml xml
    parsed_xml = Nokogiri::XML(xml).remove_namespaces!

    @id = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="9"]').text

    @item_type = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="y"]').text
  end


end
