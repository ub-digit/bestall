class Item
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :biblio_id, :sublocation_id, :item_type, :barcode, :item_call_number,
                :copy_number, :public_notes, :due_date, :lost, :restricted, :not_for_loan, :is_reserved,
                :withdrawn, :in_transit, :location_id, :location_name_sv,:sublocation_open_loc

  attr_writer :found

  def initialize biblio_id:, rawdata:, has_item_level_queue: false
    @biblio_id = biblio_id
    @has_item_level_queue = has_item_level_queue
    @is_reserved = false
    parse_rawdata(rawdata)
    sublocation = Sublocation.find_by_id(@sublocation_id)
    @sublocation_open_loc = sublocation_open_loc?
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
    return false if reserved?
    return false if checked_out?
    return false if not_in_place?
    return false if during_acquisition?
    return false if in_transit?
    return true
  end


  def can_be_ordered
    # TODO Extend with more rules

    return false unless @item_type
    return false if item_type_ref?
# CORONA: Make Kursbok orderable
#    return false if item_type_kursbok?
    return false if checked_out?
    return false if reserved?
    return false if lost?
    return false if during_acquisition?
    return false if not_in_place?
    return false if in_transit?
    return false unless sublocation_paging_loc?
    return true
  end

  def can_be_queued
    @has_item_level_queue && is_available_for_queue
  end

  def is_available_for_queue
    return false if item_type_ref?
    return false if restricted?
    return false unless checked_out? || reserved? || during_acquisition? || not_in_place? || in_transit?
    return true
  end

  def sublocation_paging_loc?
    Sublocation.find_by_id(@sublocation_id).is_paging_loc == '1'
  end

  def sublocation_open_loc?
    Sublocation.find_by_id(@sublocation_id).is_open_loc == '1'
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
    ['1', '2', '3'].include?(@withdrawn) || ['1', '5'].include?(@lost)
  end

  def not_in_place?
    @lost == '4'
  end

  def during_acquisition?
    @withdrawn == '4'
  end

  def in_transit?
    @in_transit == '1' || (@currentlocation_id != @location_id)
  end

  def status_limitation
    return "NOT_FOR_HOME_LOAN" if item_type_ref?
    return "READING_ROOM_ONLY" if @not_for_loan == '-3'
    return "LOAN_IN_HOUSE_ONLY" if ['3', '4', '5', '6', '7', '8'].include?(@restricted)
  end

  def status
    return "LOANED" if @due_date.present? && Date.parse(@due_date) >= Date.today
    return "RESERVED" if (@is_reserved && @due_date.blank?) || @found == "W" || @found == "T"
    return "DELAYED" if (@due_date.present? && Date.parse(@due_date) < Date.today) || ['2', '3', '6'].include?(@lost)
    return "IN_TRANSIT" if in_transit?
    return "NOT_IN_PLACE" if not_in_place?
    return "DURING_ACQUISITION" if during_acquisition?
    return "AVAILABLE"
  end

  def parse_rawdata rawdata
    rawdata["itemnumber"].present? ? @id = rawdata["itemnumber"] : @id = nil
    rawdata["location"].present? ? @sublocation_id = rawdata["location"] : @sublocation_id = nil
    rawdata["itype"].present? ? @item_type = rawdata["itype"].to_s : @item_type = nil
    rawdata["barcode"].present? ? @barcode = rawdata["barcode"] : @barcode = nil
    rawdata["itemcallnumber"].present? ? @item_call_number = rawdata["itemcallnumber"] : @item_call_number = nil
    rawdata["enumchron"].present? ? @copy_number = rawdata["enumchron"] : @copy_number = nil
    rawdata["itemnotes"].present? ? @public_notes = rawdata["itemnotes"] : @public_notes = nil
    rawdata["itemlost"].present? ? @lost = rawdata["itemlost"].to_s : @lost = nil
    rawdata["restricted"].present? ? @restricted = rawdata["restricted"].to_s : @restricted = nil
    rawdata["notforloan"].present? ? @not_for_loan = rawdata["notforloan"].to_s : @not_for_loan = nil
    rawdata["withdrawn"].present? ? @withdrawn = rawdata["withdrawn"].to_s : @withdrawn = nil
    rawdata["datedue"].present? ? @due_date = rawdata["datedue"] : @due_date = nil
    rawdata["in_transit"].present? ? @in_transit = rawdata["in_transit"] : @in_transit = nil
    rawdata["holdingbranch"].present? ? @currentlocation_id = rawdata["holdingbranch"] : @currentlocation_id = nil
  end
end

