class User
  attr_accessor :id, :username, :first_name, :last_name, :denied, :warning, :fines_amount, :reserves, :loans
  attr_reader :restriction_fines, :restriction_av, :restriction_or, :restriction_ori, :restriction_overdue, :user_category

  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  def as_json options = {}
    result = super(except: ['xml'])
    if @denied
      result[:denied_reasons] = {restriction_av: @restriction_av, restriction_ori: @restriction_ori}
    else
      result[:denied_reasons] = nil
    end
    if @warning
      result[:warning_reasons] = {restriction_fines: @restriction_fines, restriction_or: @restriction_or, restriction_overdue: @restriction_overdue}
    else
      result[:warning_reasons] = nil
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

  def has_borrowed_item? biblio_id
    return !@loans.select{|loan| loan[:biblionumber].eql? biblio_id}.empty?
  end

  def has_reserved_item? biblio_id
    return !@reserves.select{|reserve| reserve[:biblionumber].eql? biblio_id}.empty?
  end

  def parse_xml
    xml = Nokogiri::XML(@xml).remove_namespaces!

    if xml.search('//response/borrower/categorycode').text.present?
      @user_category = xml.search('//response/borrower/categorycode').text
    end
    if xml.search('//response/borrower/borrowernumber').text.present?
      @id = xml.search('//response/borrower/borrowernumber').text.to_i
    end
    if xml.search('//response/borrower/surname').text.present?
      @last_name = xml.search('//response/borrower/surname').text
    end
    if xml.search('//response/borrower/firstname').text.present?
      @first_name = xml.search('//response/borrower/firstname').text
    end

    @denied = false # spärrad
    @warning = false # ska varnas
    @fines_amount = nil # bötesbelopp
    @restriction_fines = false # böter mer än 69 kr
    @restriction_av = false # avstängd
    @restriction_or = false # obetald räkning
    @restriction_ori = false # obetald räkning inkasso
    @restriction_overdue = false # 2a krav

    # TBD remove this, when AV is moved from patron category
    if xml.search('//response/borrower/categorycode').text.present? && xml.search('//response/borrower/categorycode').text == 'AV'
      @restriction_av = true
      @denied = true
    end

    xml.xpath('//response/debarments').each do |debarment|
      if debarment.xpath('comment').text.starts_with?('AV, ')
        @restriction_av = true
        @denied = true
      end
      if debarment.xpath('comment').text.starts_with?('OR, ')
        @restriction_or = true
        @warning = true
      end
      if debarment.xpath('comment').text.starts_with?('ORI, ')
        @restriction_restriction_ori = true
        @denied = true
      end
      if debarment.xpath('comment').text.starts_with?('OVERDUES_PROCESS ')
        @restriction_overdue = true
        @warning = true
      end
    end

    xml.xpath('//response/flags').each do |flag|
      if flag.xpath('name').text == 'CHARGES'
        if flag.xpath('amount').text.to_i > 69
          @restriction_fines = true
          @warning = true
        end
        @fines_amount = flag.xpath('amount').text
      end
    end

    @loans = []
    xml.xpath('//response/issues').each do |issue|
      if issue.xpath('returndate').text.blank?
        biblionumber = issue.xpath('biblionumber').text
        itemnumber = issue.xpath('itemnumber').text
        @loans << {biblionumber: biblionumber, itemnumber: itemnumber}
      end
    end

    @reserves = []
    xml.xpath('//response/reserves/anon').each do |reserve|
        biblionumber = reserve.xpath('biblionumber').text
        itemnumber = reserve.xpath('itemnumber').text
        @reserves << {biblionumber: biblionumber, itemnumber: itemnumber}
    end

  end

end
