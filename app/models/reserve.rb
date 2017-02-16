class Reserve
  attr_accessor :id, :borrowernumber, :biblionumber, :itemnumber, :branchcode, :reservedate, :timestamp

  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  def initialize xml=nil
    @xml = xml
    parse_xml if @xml
  end

  def self.add borrowernumber:, branchcode:, biblionumber:, itemnumber: nil
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    url = "#{base_url}/reserves/create?userid=#{user}&password=#{password}&borrowernumber=#{borrowernumber}&biblionumber=#{biblionumber}&itemnumber=#{itemnumber}&branchcode=#{branchcode}"
    response = RestClient.get url
    if response && response.code == 201
      item = self.new response.body
      return item
    else
      return nil
    end

    #TODO: Add error handling
  rescue => error
    return nil
  end

  def parse_xml
    xml = Nokogiri::XML(@xml).remove_namespaces!

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
  end

end
