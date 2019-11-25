class Biblio
  attr_accessor :id, :title, :origin, :isbn, :edition, :items, :record_type, :no_in_queue, :subscriptiongroups, :biblio_call_number

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
    !@subscriptiongroups.empty? || @items.any? {|item| item.can_be_borrowed}
  end

  # TODO: !has_item_level_queue check redundant?
  def can_be_queued
    !has_item_level_queue && @items.any? {|item| item.is_available_for_queue}
  end

  def has_available_kursbok
    @items.any? {|item| item.is_availible && item.item_type_kursbok?}
  end

  def has_item_level_queue
    # Biblios wrongly cataloged as monographs should be considered as serials if subscriptions exist
    !@subscriptiongroups.empty? || Biblio.queue_level(@record_type) == 'item'
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
    super.merge(can_be_queued: can_be_queued, has_item_level_queue: has_item_level_queue, has_available_kursbok: has_available_kursbok)
  end

  def initialize id, bib_xml, items_data, reserves_data, subscriptions
    @id = id
    @subscriptiongroups = []
    parse_data bib_xml, items_data, reserves_data
    if !subscriptions.empty?
      #order subscriptions by home library
      grouped_subscriptions = subscriptions.group_by do |sub|
          sub.location_id
      end

      #map library code against sigel
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

      shortInfoHash = self.findShortInfo bib_xml
      grouped_subscriptions.each_key do |location_id|
        short_info = self.getShortInfo shortInfoHash, libmap[location_id.to_i].to_s
        sg = Subscriptiongroup.new short_info, grouped_subscriptions[location_id], location_id, self.id
        @subscriptiongroups.unshift(sg)
      end
    end
  end

  def findShortInfo bib_xml
    info_result = {}
    bib_xml = Nokogiri::XML(bib_xml).remove_namespaces!
    bib_xml.search('//record/datafield[@tag="866"]').each do |sto|

      if sto.search('subfield[@code="a"]').text.present? || sto.search('subfield[@code="z"]').text.present?
        sigel = sto.search('subfield[@code="5"]').text
        subscription_stock = sto.search('subfield[@code="a"]').text
        item_type = sto.search('subfield[@code="z"]').text

        if !info_result[sigel]
          info_result[sigel] = []
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
        info_result[sigel] << res
      end
    end
    return info_result
  end

  def getShortInfo shortInfoHash, key
    if shortInfoHash.key?(key)
        return shortInfoHash[key]
    end
    return nil
  end


  def self.find id, opts = {}
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']

    bib_url = "#{base_url}/bib/#{id}?userid=#{user}&password=#{password}"
    bib_response = RestClient.get bib_url
    bib_response_body = bib_response.body

    subscriptions = Subscription.find_by_biblio_id id

    if !subscriptions.empty? && opts[:items_on_subscriptions].eql?("false")
      # set json with empty item and reserve arrays
      items_response_body = "{\"items\": []}"
      reserves_response_body = "{\"reserves\": []}"
    else
      items_url = "#{base_url}/items/list?biblionumber=#{id}&userid=#{user}&password=#{password}"
      items_response = RestClient.get items_url
      items_response_body = items_response.body
      reserves_url = "#{base_url}/reserves/list?biblionumber=#{id}&userid=#{user}&password=#{password}"
      reserves_response = RestClient.get reserves_url
      reserves_response_body = reserves_response.body
    end

    item = self.new id, bib_response_body, items_response_body, reserves_response_body, subscriptions
    return item
  end

  def self.find_by_id id, opts = {}
    self.find id, opts
    # TODO: Do something much better
    rescue RestClient::NotFound => error
      return nil
    rescue => error
      return nil
  end

  def parse_data bib_xml, items_data, reserves_data
    bib_xml = Nokogiri::XML(bib_xml).remove_namespaces!

    @record_type = Biblio.parse_record_type(bib_xml.search('//record/leader').text)

    @title = nil
    @origin = nil
    @isbn =  nil
    @edition = nil
    @has_enum = nil
    @biblio_call_number = nil

    if bib_xml.search('//record/datafield[@tag="095"]/subfield[@code="a"]').text.present?
      @biblio_call_number = bib_xml.search('//record/datafield[@tag="095"]/subfield[@code="a"]').text
    end

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

    reserves = JSON.parse(reserves_data)["reserves"]
    JSON.parse(items_data)["items"].each do |item_data|
      item = Item.new(biblio_id: self.id, rawdata: item_data, has_item_level_queue: self.has_item_level_queue)
      next if !item.is_valid? || item.masked?
      item.is_reserved = false
      reserves.each do |reserve|
        if reserve["itemnumber"].present?
          if reserve["itemnumber"] == item.id
            item.is_reserved = true
            if reserve["found"].present?
              item.found = reserve["found"]
            end
          end
        else
          borrower = reserve["borrowernumber"]
          if !borrowers.include? borrower
            borrowers.push(borrower)
             # increase only when itemnumber is not included
            @no_in_queue += 1
          end
        end
      end
      @items << item
      if item.copy_number
        @has_enum = true
      end
    end

    # Sort items
    @items = @items.sort_by { |a| [ a.location_id || "", a.sublocation_id || "", a.item_call_number || "" ] }
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
