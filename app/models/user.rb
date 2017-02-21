class User
  attr_accessor :id, :username, :first_name, :last_name, :denied, :fines_amount

  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  def as_json options = {}
    result = super(except: ['xml', 'banned', 'fines', 'debarred', 'no_address', 'card_lost', 'expired'])
    if @denied
      result[:denied_reasons] = {banned: @banned, fines: @fines, debarred: @debarred, no_address: @no_address, card_lost: @card_lost, expired: @expired}
    else
      result[:denied_reasons] = nil
    end
    return result
  end

  def initialize username, xml=nil
    @username = username
    @xml = xml
    parse_xml if @xml
  end

  def self.find id
    # not implemented
    return nil
  end

  def self.find_by_username username
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    url = "#{base_url}/members/get?borrower=#{username}&userid=#{user}&password=#{password}"
    response = RestClient.get url
    item = self.new username, response.body
    return item
  rescue => error
    return nil
  end


  # Password not used with CAS, left in place for later. Force auth will be true for CAS
  def authenticate(provided_password, force_authenticate=false)
    if force_authenticate
      token_object = AccessToken.generate_token(self)
      return token_object.token
    end
    return nil
  end

  def parse_xml
    xml = Nokogiri::XML(@xml).remove_namespaces!

    if xml.search('//response/borrower/surname').text.present?
      @last_name = xml.search('//response/borrower/surname').text
    end
    if xml.search('//response/borrower/firstname').text.present?
      @first_name = xml.search('//response/borrower/firstname').text
    end
    if xml.search('//response/borrower/borrowernumber').text.present?
      @id = xml.search('//response/borrower/borrowernumber').text.to_i
    end

    @denied = false # spärrad

    @fines_amount = nil # bötesbelopp

    @banned = false # avstängd (AV)
    @fines = false # böter mer än 69 kr
    @debarred = false # utgånget lånekort
    @no_address = false # saknar adress
    @card_lost = false # förlorat lånekort
    @expired = false # utgånget

    if xml.search('//response/borrower/categorycode').text.present? && xml.search('//response/borrower/categorycode').text == 'AV'
      @banned = true
      @denied = true
    end

    if xml.search('//response/borrower/dateexpiry').text.present?
      date_expiry = xml.search('//response/borrower/dateexpiry').text
      if date_expiry && (Date.parse(date_expiry) < Date.today)
        @expired = true
        @denied = true
      end
    end
    xml.xpath('//response/flags').each do |flag|
      if flag.xpath('name').text == 'CHARGES'
        if flag.xpath('amount').text.to_i > 69
          @fines = true
          @denied = true
        end
        @fines_amount = flag.xpath('amount').text
      end
      if flag.xpath('name').text == 'DBARRED'
        @debarred = true
        @denied = true
      end
      if flag.xpath('name').text == 'GNA'
        @no_address = true
        @denied = true
      end
      if flag.xpath('name').text == 'LOST'
        @card_lost = true
        @denied = true
      end
    end
  end

end
