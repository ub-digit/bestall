class Reserve
  attr_accessor :id, :borrowernumber, :biblionumber, :itemnumber, :branchcode, :reservedate, :timestamp, :reservenotes

  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

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
    response = RestClient.get url
    if response
      if response.code == 201
        obj = Reserve.new
        obj.parse_xml(response.body)
        return obj
      else
        auth_status = self.parse_error(response.body)
        return {code: response.code, msg: auth_status, errors: nil}
      end
    else
      return nil
    end
  rescue => error
    auth_status = self.parse_error(error.response.try(:body))
    return {code: error.response.try(:code), msg: auth_status, errors: nil}
  end

  def self.parse_error(xml_response)
    xml = Nokogiri::XML(xml_response).remove_namespaces!
    auth_status = 'Something is wrong but we did not find the reason'
    if xml.search('//response/auth_status').text.present?
      auth_status = xml.search('//response/auth_status').text
    end
    return auth_status
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
  end

end
