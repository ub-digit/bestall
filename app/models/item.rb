class Item
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :biblio_id, :sublocation_id, :item_type, :barcode, :item_call_number,
                :copy_number, :due_date, :lost, :restricted, :not_for_loan, :is_reserved,
                :recently_returned

  attr_writer :found

  def initialize biblio_id:, xml:, has_item_level_queue: false
    @biblio_id = biblio_id
    @has_item_level_queue = has_item_level_queue
    @is_reserved = false
    parse_xml(xml)
  end

  def as_json options = {}
    super(except: ["found"]).merge({can_be_ordered: can_be_ordered,
      can_be_queued: can_be_queued,
      status: status
      }).compact
  end

  def can_be_borrowed
    # TODO Extend with more rules
    !item_type_ref?
  end

  def can_be_ordered
    # TODO Extend with more rules

    return false unless @item_type
    return false if item_type_ref?
    return false if item_type_kursbok?
    return false if checked_out?
    return false if reserved?
    return false if lost?
    return false if restricted?
    return false unless sublocation_paging_loc?
    return true
  end

  def can_be_queued
    @has_item_level_queue && is_available_for_queue
  end

  def is_available_for_queue
    return false if item_type_ref?
    return false if restricted?
    return false unless checked_out? || reserved?
    return true
  end

  def sublocation_paging_loc?
    Sublocation.find_by_id(@sublocation_id).is_paging_loc == '1'
  end

  def lost?
    @lost != '0'
  end

  def checked_out?
    @due_date.present?
  end

  def reserved?
    @is_reserved
  end

  def restricted?
    # ['1', '2', '5', '6'].include?(@restricted)
    !(@restricted == '0' || @restricted.nil?)
  end

  def item_type_ref?
    @item_type == '7'
  end

  def item_type_kursbok?
    @item_type == '2'
  end

  def status
    return "IN_TRANSIT" if @found == "T"
    return "FINISHED" if @found == "F"
    return "WAITING" if @found == "W"
    return "CAN_BE_ORDERED" if can_be_ordered
    return "LOANED" if @due_date.present?
    return "RESERVED" if @is_reserved
    return "RECENTLY_RETURNED" if @recently_returned
  end

  def parse_xml xml
    parsed_xml = Item.process_xml xml

    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="9"]').text.present?
      @id = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="9"]').text
    end

    if parsed_xml.search('//datafield[@tag="952"]/subfield[@code="v"]').text.present?
      @sublocation_id = parsed_xml.search('//datafield[@tag="952"]/subfield[@code="v"]').text
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

    @recently_returned = Item.parse_recently_returned parsed_xml

  end

  def self.process_xml xml
    return xml if xml.kind_of?(Nokogiri::XML::Document)
    Nokogiri::XML(xml).remove_namespaces!
  end

  def self.parse_recently_returned xml
    process_xml(xml).search('//datafield[@tag="952"]/subfield[@code="c"]').text == "CART"
  end
end
