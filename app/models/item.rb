class Item
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :biblio_id, :sublocation_id, :item_type, :barcode, :item_call_number,
                :copy_number, :public_notes, :due_date, :lost, :restricted, :not_for_loan, :is_reserved,
                :withdrawn, :in_transit, :location_id, :location_name_sv, :sublocation_open_loc

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
    !item_type_ref? && !not_for_loan_reference_copy?
    # TODO: restricted?
    # TODO: not_for_loan??
  end

  def is_availible
    #status == "AVAILABLE"
    # andra lost statusar? in_transit statusar?
    #!(reserved? || checked_out? || lost_not_in_place? || withdrawn_during_acquisition? || in_transit?)
    !(reserved? || checked_out? || lost? || withdrawn_during_acquisition? || in_transit?)
  end

  def can_be_ordered
    is_availible &&
      can_be_borrowed &&
      !restricted? &&
      !item_type_kursbok? && #can_be_borrowed??
      sublocation_paging_loc?
  end

  def can_be_queued
    @has_item_level_queue && is_available_for_queue
  end

  # can_be_borrowed should also include not_for_loan?
  def is_available_for_queue
    !is_available && can_be_borrowed && !restricted? # Ang: restricted se rules.pdf
  end

  def sublocation_paging_loc?
    Sublocation.find_by_id(@sublocation_id).is_paging_loc == '1'
  end

  # TODO: This is not currently used I think
  def sublocation_open_loc?
    Sublocation.find_by_id(@sublocation_id).is_open_loc == '1'
  end

  def lost?
    @lost != '0'
  end
  def lost_not_in_place?
    @lost == '4'
  end
  def lost_missing?
    @lost == '1'
  end
  def lost_to_invoicing?
    @lost == '2'
  end

  # TODO: Not currently used?
  def checked_out?
    @due_date.present?
  end

  def reserved?
    @is_reserved.present?
  end

  def restricted?
    # ['1', '2', '5', '6'].include?(@restricted)
    # return "LOAN_IN_HOUSE_ONLY" if ['3', '4', '5', '6'].include?(@restricted) ???
    !(@restricted == '0' || @restricted.nil?)
  end

  # select count(*) from items where itype = 7 AND notforloan = 0\G
  def item_type_ref?
    @item_type == '7'
  end

  def item_type_kursbok?
    @item_type == '2'
  end

  def masked?
    ['1', '2', '3'].include?(@withdrawn) || lost_missing?
  end

  def is_valid?
    #TODO: check for sublocation instead?
    @item_type.present? && sublocation_id.present?
  end

  def withdrawn_during_acquisition?
    @withdrawn == '4'
  end

  def in_transit?
    @in_transit == '1' || (@currentlocation_id != @location_id)
  end

  def status_limitation
    # return nil if not_for_loan?
    return "NOT_FOR_HOME_LOAN" if item_type_ref? # || not_for_loan_reference_copy? ?? TODO: red ut om kan ta bort det ena eller andra
    return "READING_ROOM_ONLY" if not_for_loan_reading_room_only?
    return "LOAN_IN_HOUSE_ONLY" if ['3', '4', '5', '6'].include?(@restricted) # is_restricted differance?? TOOD: change to is_restricted ?
  end

  # if lost = 1 will have status available?
  # TODO: Ga igenom alla statusar och se om makes sense och om saknas state
  # Kanske loopa igenom alla items och se resultatstates
  def status
    return "AVAILABLE" if is_availible
    return "LOANED" if @due_date.present? && Date.parse(@due_date) >= Date.today
    return "DELAYED" if (@due_date.present? && Date.parse(@due_date) < Date.today) || lost_to_invoicing?
    # lost statuses 5, 6, 7... etc exists? can remove?
    # found_in_transit vs in_transit, RESERVED or IN_TRANSIT
    # Kan ha found status utan vara reserverad??
    # @due_date.blank? behovs inte iom kollat ovan
    return "RESERVED" if (reserved? && @due_date.blank?) # || ['5', '6', '7', '8','9'].include?(@lost) || found_waiting? || found_in_transit?
    return "IN_TRANSIT" if in_transit?
    return "NOT_IN_PLACE" if lost_not_in_place? # lost_missing kollas i masked? !!
    return "DURING_ACQUISITION" if withdrawn_during_acquisition?
    return "AVAILABLE" # UNKNOWN!! ??
  end

  def not_for_loan?
    @not_for_loan != '0' || item_type_ref? ###????
  end
  def not_for_loan_reading_room_only?
    @not_for_loan == '-3'
  end
  def not_for_loan_reference_copy?
    @not_for_loan == '-2'
  end


  # Tror kan skita i found? iom att felaktiga found states uppenbarligen uppkommer
  # relativt ofta (verifierat via databasfragor i produktion)
  # gar alltsa inte att lita pa
  def found?
    @found.present?
  end
  def found_waiting?
    @found == "W"
  end
  def found_in_transit?
    @found == "T"
  end

  def parse_rawdata rawdata
    rawdata["itemnumber"].present? ? @id = rawdata["itemnumber"] : @id = nil
    rawdata["location"].present? ? @sublocation_id = rawdata["location"] : @sublocation_id = nil
    rawdata["itype"].present? ? @item_type = rawdata["itype"] : @item_type = nil
    rawdata["barcode"].present? ? @barcode = rawdata["barcode"] : @barcode = nil
    rawdata["itemcallnumber"].present? ? @item_call_number = rawdata["itemcallnumber"] : @item_call_number = nil
    rawdata["enumchron"].present? ? @copy_number = rawdata["enumchron"] : @copy_number = nil
    rawdata["itemnotes"].present? ? @public_notes = rawdata["itemnotes"] : @public_notes = nil
    rawdata["itemlost"].present? ? @lost = rawdata["itemlost"] : @lost = "0" # Better safe than sorry
    rawdata["restricted"].present? ? @restricted = rawdata["restricted"] : @restricted = nil
    rawdata["notforloan"].present? ? @not_for_loan = rawdata["notforloan"] : @not_for_loan = nil
    rawdata["withdrawn"].present? ? @withdrawn = rawdata["withdrawn"] : @withdrawn = nil
    rawdata["datedue"].present? ? @due_date = rawdata["datedue"] : @due_date = nil
    rawdata["in_transit"].present? ? @in_transit = rawdata["in_transit"] : @in_transit = nil
    rawdata["holdingbranch"].present? ? @currentlocation_id = rawdata["holdingbranch"] : @currentlocation_id = nil
  end
end

