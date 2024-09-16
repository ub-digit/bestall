class Reserve
  require "prawn/measurement_extensions"
  attr_accessor :id, :borrowernumber, :biblionumber, :itemnumber, :branchcode, :reservedate, :timestamp, :reservenotes, :queue_position

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

  def self.add(borrowernumber:, branchcode:, biblionumber:, itemnumber: nil, reservenotes:)
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    params = {
      userid: user,
      password: password,
      borrowernumber: borrowernumber,
      biblionumber: biblionumber,
      itemnumber: itemnumber,
      branchcode: branchcode,
      reservenotes: reservenotes
    }.to_query

    url = "#{base_url}/reserves/create?#{params}"
    response = RestClient.get(url, timeout: 600)
    if response
      if response.code == 201
        obj = Reserve.new
        obj.parse_xml(response.body)
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
      @queue_position = xml.search('//response/queue_position').text
    else
      @queue_position = nil
    end
  end

end
