class Reserve
  require "prawn/measurement_extensions"
  attr_accessor :id, :cardnumber, :biblionumber, :itemnumber, :branchcode, :reservedate, :timestamp,
    :reservenotes, :showQueuePosition, :positionInQueue, :item_referenced, :pickupLocation_en, :pickupLocation_sv, :showPickupLocation, :showMyLoansLink

  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  # Converts a Koha and CGI Error Code into an error code for use in a client app.
  # If the code is not found among known error codes
  # a default error code is returned.
  ## Koha error_codes:
  # 'damaged',
  # 'ageRestricted',
  # 'itemAlreadyOnHold',
  # 'tooManyReserves',
  # 'notReservable',
  # 'cannotReserveFromOtherBranches',
  # 'tooManyHoldsForThisRecord'
  ## Extra CGI error_codes:
  # 'borrowerNotFound',
  # 'branchCodeMissing'
  # 'itemnumberOrBiblionumberIsMissing'
  # 'biblionumberIsMissing'
  # 'itemDoesNotBelongToBiblio'
  # 'unrecognizedError'
  def self.error_code(koha_code)
    known_error_codes = [
      'damaged',
      'ageRestricted',
      'itemAlreadyOnHold',
      'tooManyReserves',
      'notReservable',
      'cannotReserveFromOtherBranches',
      'tooManyHoldsForThisRecord',
      'borrowerNotFound',
      'branchCodeMissing',
      'itemnumberOrBiblionumberIsMissing',
      'biblionumberIsMissing',
      'itemDoesNotBelongToBiblio',
      'unrecognizedError'
    ]
    return (known_error_codes.include?(koha_code) ?
      koha_code.underscore.upcase :
      'UNRECOGNIZED_ERROR')
  end

  def self.add(cardnumber:, branchcode:, biblionumber:, itemnumber: nil, reservenotes:, loan_type_obj:, has_item_level_queue: false)
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    if loan_type_obj.send_material?
      # Get pickup location from the Location object
      pickup_location_id = Location.find_by_id(branchcode).pickup_location_id
      showPickupLocation = false
    else
      # Use homebranch as pickup location
      pickup_location_id = branchcode
      showPickupLocation = true
    end

    params = {
      login_userid: user,
      login_password: password,
      cardnumber: cardnumber,
      biblionumber: biblionumber,
      itemnumber: itemnumber,
      branchcode: pickup_location_id,
      reservenotes: reservenotes
    }.to_query

    showQueuePosition = !has_item_level_queue
    # Check this
    showMyLoansLink = true

    url = "#{base_url}/reserves/create?#{params}"
    response = RestClient.get url
    if response
      if response.code == 201
        obj = Reserve.new
        obj.parse_xml(response.body)
        obj.showQueuePosition = showQueuePosition
        obj.showPickupLocation = showPickupLocation
        obj.showMyLoansLink = showMyLoansLink
        pp obj
        return obj
      else
        error_list = self.parse_error(response.body)
        return {code: response.code, msg: error_list[0][:detail], errors: error_list}
      end
    else
      return nil
    end
  rescue => error
    error_list = self.parse_error(error.response.try(:body))
    return {code: error.response.try(:code), msg: error_list[0][:detail], errors: error_list}
  end

  def self.parse_error(xml_response)
    xml = Nokogiri::XML(xml_response).remove_namespaces!
    status = 'Something is wrong but we did not find the reason'
    if xml.search('//response/status').text.present?
      status = xml.search('//response/status').text
    end
    if xml.search('//response/error_code').text.present?
      error_code = xml.search('//response/error_code').text
    end
    [{code: Reserve.error_code(error_code), detail: status}]
  end

  def parse_xml(xml_response)
    return if !xml_response
    xml = Nokogiri::XML(xml_response).remove_namespaces!

    if xml.search('//response/reserve/reserve_id').text.present?
      @id = xml.search('//response/reserve/reserve_id').text.to_i
    end
    if xml.search('//response/reserve/borrowernumber').text.present?
      @borrowernumber = xml.search('//response/reserve/borrowernumber').text
    end
    if xml.search('//response/reserve/biblionumber').text.present?
      @biblionumber = xml.search('//response/reserve/biblionumber').text
    end
    if xml.search('//response/reserve/itemnumber').text.present?
      @itemnumber = xml.search('//response/reserve/itemnumber').text
    end
    if xml.search('//response/reserve/branchcode').text.present?
      location = Location.find_by_id(xml.search('//response/reserve/branchcode').text)
      pp location
      @pickupLocation_en = location.name_en
      @pickupLocation_sv = location.name_sv
      @branchcode = xml.search('//response/reserve/branchcode').text
    end
    if xml.search('//response/reserve/reservedate').text.present?
      @reservedate = xml.search('//response/reserve/reservedate').text
    end
    if xml.search('//response/reserve/timestamp').text.present?
      @timestamp = xml.search('//response/reserve/timestamp').text
    end
    if xml.search('//response/reserve/reservenotes').text.present?
      @reservenotes = xml.search('//response/reserve/reservenotes').text
    end
    if xml.search('//response/queue_position').text.present?
      @positionInQueue = xml.search('//response/queue_position').text
    else
      @positionInQueue = nil
    end
    if xml.search('//response/item_referenced').text.present?
      @item_referenced = (xml.search('//response/item_referenced').text == "true") ? true : false
    else
      @item_referenced = false
    end
  end

end
