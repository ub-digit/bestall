class Borrower
  attr_accessor :userid, :lastname, :firstname, :locked, :amount

  include ActiveModel::Serialization
  include ActiveModel::Validations

  def as_json options = {}
    result = super(except: ['xml', 'banned', 'fines', 'debarred', 'no_address', 'card_lost', 'expired'])
    if @locked
      result[:locked_reasons] = {banned: @banned, fines: @fines, debarred: @debarred, no_address: @no_address, card_lost: @card_lost, expired: @expired}
    else
      result[:locked_reasons] = nil
    end
    return result
  end

  def initialize userid, xml
    @userid = userid
    @xml = xml
    parse_xml
  end

  def self.find id
    # not implemented
    return nil
  end

  def self.find_by_userid userid
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    url = "#{base_url}/members/get?borrower=#{userid}&userid=#{user}&password=#{password}"
    response = RestClient.get url
    item = self.new userid, response.body
    return item
  #rescue => error
  #  return nil
  end

  def parse_xml
    xml = Nokogiri::XML(@xml).remove_namespaces!

    if xml.search('//response/borrower/surname').text.present?
      @lastname = xml.search('//response/borrower/surname').text
    end
    if xml.search('//response/borrower/firstname').text.present?
      @firstname = xml.search('//response/borrower/firstname').text
    end


    @locked = false # spärrad

    @banned = false # avstängd (AV)
    @fines = false # böter mer än 69 kr
    @amount = nil # bötesbelopp
    @debarred = false # utgånget lånekort
    @no_address = false # saknar adress
    @card_lost = false # förlorat lånekort
    @expired = false # utgånget

    if xml.search('//response/borrower/categorycode').text.present? && xml.search('//response/borrower/categorycode').text == 'AV'
      @banned = true
      @locked = true
    end

    if xml.search('//response/borrower/dateexpiry').text.present?
      date_expiry = xml.search('//response/borrower/dateexpiry').text
      if date_expiry && (Date.parse(date_expiry) < Date.today)
        @expired = true
        @locked = true
      end
    end
    xml.xpath('//response/flags').each do |flag|
      if flag.xpath('name').text == 'CHARGES'
        if flag.xpath('amount').text.to_i > 69
          @fines = true
          @locked = true
        end
        @amount = flag.xpath('amount').text
      end
      if flag.xpath('name').text == 'DBARRED'
        @debarred = true
        @locked = true
      end
      if flag.xpath('name').text == 'GNA'
        @no_address = true
        @locked = true
      end
      if flag.xpath('name').text == 'LOST'
        @card_lost = true
        @locked = true
      end
    end
  end

end


