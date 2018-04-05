class Item
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :biblio_id, :sublocation_id, :item_type, :barcode, :item_call_number,
                :copy_number, :due_date, :lost, :restricted, :not_for_loan, :is_reserved, :withdrawn, :location_id

  attr_writer :found

  def initialize biblio_id:, rawdata:, has_item_level_queue: false
    @biblio_id = biblio_id
    @has_item_level_queue = has_item_level_queue
    @is_reserved = false
    parse_rawdata(rawdata)
    sublocation = Sublocation.find_by_id(@sublocation_id)
    @sublocation_name_sv = sublocation.name_sv
    @sublocation_name_en = sublocation.name_en
    @location_id = sublocation.location_id
    location = Location.find_by_id(@location_id)
    @location_name_sv = location.name_sv
    @location_name_en = location.name_en
  end

  def as_json options = {}
    super(except: ["found"]).merge({can_be_ordered: can_be_ordered,
      can_be_queued: can_be_queued,
      status: status,
      status_limitation: status_limitation,
      is_availible: is_availible
      }).compact
  end

  def can_be_borrowed
    # TODO Extend with more rules
    !item_type_ref?
  end

  def is_availible
    return false if is_reserved
    return false if due_date.present?
    return false if not_in_place?
    return false if during_acquisition?
    return true
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

  def masked?
    ['1', '2', '3'].include?(@withdrawn) || @lost == '1'
  end

  def not_in_place?
    @lost == '4'
  end

  def during_acquisition?
    @withdrawn == '4'
  end

  def status_limitation
    return "NOT_FOR_HOME_LOAN" if item_type_ref?
    return "READING_ROOM_ONLY" if @not_for_loan == '-3'
    return "LOAN_IN_HOUSE_ONLY" if ['3', '4', '5', '6'].include?(@restricted)
  end

  def status
    return "LOANED" if @due_date.present? && Date.parse(@due_date) >= Date.today
    return "WAITING" if @found == "W"
    return "IN_TRANSIT" if @found == "T"
    return "FINISHED" if @found == "F"
    return "RESERVED" if (@is_reserved && @due_date.blank?) || ['5', '6', '7', '8','9'].include?(@lost)
    return "DELAYED" if (@due_date.present? && Date.parse(@due_date) < Date.today) || @lost == '2'
    return "NOT_IN_PLACE" if not_in_place?
    return "DURING_ACQUISITION" if during_acquisition?
    return "AVAILABLE"
  end

  def parse_rawdata rawdata
    rawdata["itemnumber"].present? ? @id = rawdata["itemnumber"] : @id = nil
    rawdata["location"].present? ? @sublocation_id = rawdata["location"] : @sublocation_id = nil
    rawdata["itype"].present? ? @item_type = rawdata["itype"] : @item_type = nil
    rawdata["barcode"].present? ? @barcode = rawdata["barcode"] : @barcode = nil
    rawdata["itemcallnumber"].present? ? @item_call_number = rawdata["itemcallnumber"] : @item_call_number = nil
    rawdata["enumchron"].present? ? @copy_number = rawdata["enumchron"] : @copy_number = nil
    rawdata["itemlost"].present? ? @lost = rawdata["itemlost"] : @lost = nil
    rawdata["restricted"].present? ? @restricted = rawdata["restricted"] : @restricted = nil
    rawdata["notforloan"].present? ? @not_for_loan = rawdata["notforloan"] : @not_for_loan = nil
    rawdata["withdrawn"].present? ? @withdrawn = rawdata["withdrawn"] : @withdrawn = nil
    rawdata["datedue"].present? ? @due_date = rawdata["datedue"] : @due_date = nil
  end
end
