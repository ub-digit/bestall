class Biblio
  attr_accessor :id, :title, :origin, :isbn, :edition, :items, :subscriptions, :record_type, :no_in_queue

  include ActiveModel::Serialization
  include ActiveModel::Validations

  RECORD_TYPES = [
    {code: 'a', label: 'monographic_component', queue_level: 'bib'},
    {code: 'b', label: 'serial_component', queue_level: 'bib'},
    {code: 'c', label: 'collection', queue_level: 'item'},
    {code: 'd', label: 'subunit', queue_level: 'bib'},
    {code: 'i', label: 'integrating_resource', queue_level: 'bib'},
    {code: 'm', label: 'monograph', queue_level: 'bib'},
    {code: 's', label: 'serial', queue_level: 'item'}
  ]

  def can_be_borrowed
    return true if !@subscriptions.empty?
    @items.each do |item|
      return true if item.can_be_borrowed
    end
    return false
  end

  def can_be_queued
    has_items_available_for_queue = false
    has_items_available_for_queue = @items.any? {|item| item.is_available_for_queue }

    return has_items_available_for_queue && !has_item_level_queue
  end

  def has_item_level_queue
    Biblio.queue_level(@record_type) == 'item'
  end

  def has_biblio_level_queue
    Biblio.queue_level(@record_type) == 'bib'
  end

  def self.queue_level record_type
    type_obj = RECORD_TYPES.find do |type|
      type[:label] == record_type
    end

    return type_obj[:queue_level]
  end

  def as_json options = {}
    super.merge(can_be_queued: can_be_queued, has_item_level_queue: has_item_level_queue)
  end

  def initialize id, bib_xml, items_xml, reserves_xml
    @id = id
    parse_xml bib_xml, items_xml, reserves_xml
    @subscriptions = Subscription.find_by_biblio_id id
    if !@subscriptions.empty?
      puts ' --- subscriptions ----'
      pp @subscriptions
      puts ' --- end subscriptions ----'
      grouped_subscriptions = @subscriptions.group_by do |sub|
          sub.location_id
      end

      #map library
      libmap = {
        40 => 'Gm',
        42 => 'Gk',
        43 => 'Gb',
        44 => 'G',
        47 => 'Gp',
        48 => 'Ge',
        49 => 'Gg',
        50 => 'Gcl',
        60 => 'Ghdk',
        62 => 'Gumu'
      }
    
      @subscriptiongroups = []
      grouped_subscriptions.each_key do |location_id|
        short_info = self.getShortInfo libmap[location_id.to_i].to_s
        sg = Subscriptiongroup.new short_info, grouped_subscriptions[location_id], location_id, self.id
        @subscriptiongroups.unshift(sg)
      end
    end  
  end

  def getShortInfo key
    if @stock.key?(key)
        puts ' --  short info ---'
        puts @stock[key]
        puts ' --  short info end ---'
        return @stock[key]
    end
    return nil
  end
  

  def self.find id
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    bib_url = "#{base_url}/bib/#{id}?userid=#{user}&password=#{password}&items=1"
    items_url = "#{base_url}/items/list?biblionumber=#{id}&userid=#{user}&password=#{password}"
    reserves_url = "#{base_url}/reserves/list?biblionumber=#{id}&userid=#{user}&password=#{password}"

    bib_response = RestClient.get bib_url
    items_response = RestClient.get items_url
    reserves_response = RestClient.get reserves_url

    item = self.new id, bib_response, items_response, reserves_response
    return item
  end

  def self.find_by_id id
    self.find id
    # TODO: Do something much better
    rescue RestClient::NotFound => error
      return nil
    rescue => error
      return nil
  end

  def parse_xml bib_xml, items_xml, reserves_xml
    bib_xml = Nokogiri::XML(bib_xml).remove_namespaces!
    items_xml = Nokogiri::XML(items_xml).remove_namespaces!
    reserves_xml = Nokogiri::XML(reserves_xml).remove_namespaces!

    @record_type = Biblio.parse_record_type(bib_xml.search('//record/leader').text)

    @title = nil
    @origin = nil
    @isbn =  nil
    @edition = nil

    if bib_xml.search('//record/datafield[@tag="260"]').text.present?
      tmp_arr = []
      data = bib_xml.search('//record/datafield[@tag="260"]').first
      tmp_arr = tmp_arr + [data.search('subfield[@code="a"]').text, data.search('subfield[@code="b"]').text, data.search('subfield[@code="c"]').text]

      @origin = tmp_arr.join(" ").strip
    elsif bib_xml.search('//record/datafield[@tag="264" and @ind="1"]').text.present?
      tmp_arr = []
      bib_xml.search('//record/datafield[@tag="264" and @ind="1"]').each do |data|
        tmp_arr = tmp_arr + [data.search('subfield[@code="a"]').text, data.search('subfield[@code="b"]').text, data.search('subfield[@code="c"]').text]
      end
      @origin = tmp_arr.join(" ").strip
    end

    if @record_type.eql?("serial") || @record_type.eql?("collection")
      if bib_xml.search('//record/datafield[@tag="222"]').text.present?
        @title = bib_xml.search('//record/datafield[@tag="222"]').text
      else
        @title = [bib_xml.search('//record/datafield[@tag="245"]/subfield[@code="a"]').text,
                  bib_xml.search('//record/datafield[@tag="245"]/subfield[@code="b"]').text].join(" ").strip
      end
    else # monograph
      @title = [bib_xml.search('//record/datafield[@tag="245"]/subfield[@code="a"]').text,
                bib_xml.search('//record/datafield[@tag="245"]/subfield[@code="b"]').text,
                bib_xml.search('//record/datafield[@tag="245"]/subfield[@code="n"]').text,
                bib_xml.search('//record/datafield[@tag="245"]/subfield[@code="p"]').text,
                bib_xml.search('//record/datafield[@tag="245"]/subfield[@code="c"]').text].join(" ").strip

      @edition = bib_xml.search('//record/datafield[@tag="250"]/subfield[@code="a"]').text if bib_xml.search('//record/datafield[@tag="250"]/subfield[@code="a"]').text.present?
      @isbn = bib_xml.search('//record/datafield[@tag="020"]/subfield[@code="a"]').map(&:text).join("; ") if bib_xml.search('//record/datafield[@tag="020"]/subfield[@code="a"]').text.present?
    end

    @items = []
    @no_in_queue = 0
    borrowers = [];
    @stock = {};
    
    bib_xml.search('//record/datafield[@tag="866"]').each do |sto|
     
      if sto.search('subfield[@code="a"]').text.present? || sto.search('subfield[@code="z"]').text.present?
        sigel = sto.search('subfield[@code="5"]').text
        subscription_stock = sto.search('subfield[@code="a"]').text
        item_type = sto.search('subfield[@code="z"]').text
      
        if !@stock[sigel] 
          @stock[sigel] = []
        end
        res = ''
        if subscription_stock.length > 0 && 
          res += subscription_stock  
        end

        if item_type.length > 0
          if res.length > 0 
            res += ', ' + item_type
          end
        end
        @stock[sigel] << res
      end
    end
    bib_xml.search('//record/datafield[@tag="952"]').each do |item_data|
      item = Item.new(biblio_id: self.id, xml: item_data.to_xml, has_item_level_queue: self.has_item_level_queue)
      next if item.item_type.blank?
      next if item.sublocation_id.blank?
      next if item.masked?
      item.is_reserved = false
      reserves_xml.search('//response/reserve').each do |reserve|
        if reserve.xpath('itemnumber').text.present?
          if reserve.xpath('itemnumber').text == item.id
            item.is_reserved = true
            if reserve.xpath('found').text.present?
              item.found = reserve.xpath('found').text
            end
          end
        else
          borrower = reserve.xpath('borrowernumber').text
          if !borrowers.include? borrower
            borrowers.push(borrower)
             # increase only when itemnumber is not included
            @no_in_queue += 1
          end
        end
      end
      # get due date from items xml
      items_xml.search('//response/items').each do |item_xml|
        if item_xml.xpath('itemnumber').text == item.id.to_s && item_xml.xpath('datedue').text.present?
          item.due_date = item_xml.xpath('datedue').text
        end
      end
      @items << item
    end
  end

  def self.parse_record_type leader
    code = leader[7]

    type_obj = RECORD_TYPES.find do |type|
      type[:code] == code
    end

    return "other" if type_obj.nil?

    type_obj[:label]
  end

end
