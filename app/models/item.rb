class Item
  attr_accessor :id, :biblio_id, :sublocation_id, :item_type, :barcode, :item_call_number, :copy_number, :due_date, :lost, :restricted

  include ActiveModel::Serialization
  include ActiveModel::Validations

  def initialize biblio_id:, xml:
    @biblio_id = biblio_id
    parse_xml(xml)
  end

  def as_json options = {}
    super.merge({can_be_ordered: can_be_ordered}).compact

  end

  def can_be_borrowed
    # TODO Extend with more rules
    @item_type != '7'
  end

  def can_be_ordered
    # TODO Extend with more rules
    return false unless @item_type
    return false if @item_type == '7'
    return false if @item_type == '2'
    return false if @due_date.present?
    return false if @lost != '0'
    return false if @restricted != '0'
    return true
  end

  def parse_xml xml
    parsed_xml = Nokogiri::XML(xml).remove_namespaces!

    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="9"]').text.present?
      @id = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="9"]').text
    end

    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="c"]').text.present?
      @sublocation_id = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="c"]').text
    end

    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="y"]').text.present?
      @item_type = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="y"]').text
    end

    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="p"]').text.present?
      @barcode = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="p"]').text
    end

    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="o"]').text.present?
      @item_call_number = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="o"]').text
    end

    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="t"]').text.present?
      @copy_number = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="t"]').text
    end

    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="q"]').text.present?
      @due_date = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="q"]').text
    end
    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="1"]').text.present?
      @lost = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="1"]').text
    end
    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="5"]').text.present?
      @restricted = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="5"]').text
    end
  end


end
