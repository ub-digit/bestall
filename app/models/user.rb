class User
  attr_accessor :id, :username, :cardnumber, :first_name, :last_name, :denied, :warning, :fines_amount, :reserves, :loans, :attr_print
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
    if APP_CONFIG['show_pickup_code']
      result[:pickup_code] = User.create_pickup_code({lastname: @last_name, firstname: first_name, cardnumber: cardnumber, categorycode: user_category})
    else
      result[:pickup_code] = nil
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

    url = "#{base_url}/members/get?borrower=#{username}&login_userid=#{user}&login_password=#{password}"
    response = RestClient.get url
    item = self.new username, response.body
    return item
  rescue => error
    return nil
  end

  def self.authenticate cardnumber, personalnumber
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    url = "#{base_url}/members/auth?cardnumber=#{cardnumber}&personalnumber=#{personalnumber}&login_userid=#{user}&login_password=#{password}"
    response = RestClient.get url
    xml = Nokogiri::XML(response.body).remove_namespaces!
    if xml.search('//response/match').text.present?
      return xml.search('//response/match').text.eql?("true")
    end
  rescue => error
    return false
  end

  def has_borrowed_item? biblio_id
    return !@loans.select{|loan| loan[:biblionumber].eql? biblio_id}.empty?
  end

  def has_reserved_item? biblio_id
    return !@reserves.select{|reserve| reserve[:biblionumber].eql? biblio_id}.empty?
  end

  def self.create_pickup_code(obj)
    code = ""
    code = code + obj[:lastname][0,1] if obj[:lastname]
    code = code + obj[:firstname][0,1] if obj[:firstname]
    code = code + obj[:cardnumber].split(//).last(4).join
    code = code + " (" + (["SY", "FY"].include?(obj[:categorycode]) ? "Plockas fram" : obj[:categorycode]) + ")"
    return code
  end

  def self.create_name(obj)
    name = [obj[:firstname], obj[:lastname]].compact.join(" ")
    name = name + " (" + obj[:categorycode] + ")" if obj[:categorycode] && !["SY", "FY"].include?(obj[:categorycode])
    return name
  end

  def self.get_category_code(username)
    user = User.find_by_username(username)
    return user.user_category if user
    return nil
  end

  def parse_xml
    xml = Nokogiri::XML(@xml).remove_namespaces!

    if xml.search('//response/borrower/categorycode').text.present?
      @user_category = xml.search('//response/borrower/categorycode').text
    end
    if xml.search('//response/borrower/borrowernumber').text.present?
      @id = xml.search('//response/borrower/borrowernumber').text.to_i
    end
    if xml.search('//response/borrower/cardnumber').text.present?
      @cardnumber = xml.search('//response/borrower/cardnumber').text
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
        @restriction_ori = true
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

    if xml.search('//response/attributes[code="PRINT"]/attribute').text.present?
      @attr_print = xml.search('//response/attributes[code="PRINT"]/attribute').text
    end
  end

end
