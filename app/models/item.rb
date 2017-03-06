class Item
  attr_accessor :id, :biblio_id, :sublocation_id, :item_type, :barcode, :item_call_number,
                :copy_number, :due_date, :lost, :restricted, :not_for_loan, :found, :is_reserved


  include ActiveModel::Serialization
  include ActiveModel::Validations

  def initialize biblio_id:, xml:, has_item_level_queue: false
    @biblio_id = biblio_id
    @has_item_level_queue = has_item_level_queue
    @is_reserved = false
    parse_xml(xml)
  end

  def as_json options = {}
    super.merge({can_be_ordered: can_be_ordered,
      can_be_queued: can_be_queued
      }).compact
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
    return false if @is_reserved
    return false if @lost != '0'
    return false unless @restricted == '0' || @restricted.nil?
    return false unless Sublocation.find_by_id(@sublocation_id).is_paging_loc == '1'
    return true
  end

  def can_be_queued
    @has_item_level_queue && is_available_for_queue
  end

  def is_available_for_queue
    return false if @item_type == '7'
    return false if ['1', '2', '5', '6'].include?(@restricted)
    return false if @due_date.blank? && !@is_reserved
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
    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="7"]').text.present?
      @not_for_loan = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="7"]').text
    end
  end
end
