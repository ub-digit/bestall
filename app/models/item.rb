class Item
  attr_accessor :id, :biblio_id, :sublocation_id, :item_type, :barcode, :item_call_number, :copy_number

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

    @sublocation_id = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="c"]').text

    @item_type = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="y"]').text

    @barcode = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="p"]').text

    @item_call_number = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="o"]').text

    @copy_number = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="t"]').text
  end


end
