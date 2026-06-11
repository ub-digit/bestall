class Biblio
  attr_accessor :id, :title, :origin, :edition, :items, :display_info, :record_type, :no_in_queue, :subscriptiongroups, :biblio_call_number, :default_queue_location

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
    return true if !@subscriptiongroups.empty?
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

  def has_available_kursbok
    return @items.any? {|item| item.is_availible && item.item_type_kursbok?}
  end


  def has_item_level_queue
    # Biblios wrongly cataloged as monographs should be considered as serials if subscriptions exist
    return true if !@subscriptiongroups.empty?
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

  def redirect_url
    # If there are items, return nil (do not redirect)
    return nil if @complete_item_count > 0

    # If there are no items but there are subscription groups, return nil (do not redirect)
    return nil if !@subscriptiongroups.empty?

    # If there are no items and no subscription groups, return the redirect URL (if any)
    return @redirect_url
  end

  def as_json options = {}
    bib_json = {
      can_be_queued: can_be_queued,
      has_item_level_queue: has_item_level_queue,
      has_available_kursbok: has_available_kursbok,
      default_queue_location: default_queue_location,
      redirect_url: redirect_url()
    }
    super.merge(bib_json)
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

    bib_url = "#{base_url}/bib/#{id}?login_userid=#{user}&login_password=#{password}"
    bib_response = RestClient.get bib_url
    bib_response_body = bib_response.body

    subscriptions = Subscription.find_by_biblio_id id

    if !subscriptions.empty? && opts[:items_on_subscriptions].eql?("false")
      # set json with empty item and reserve arrays
      items_response_body = "{\"items\": []}"
      reserves_response_body = "{\"reserves\": []}"
    else
      items_url = "#{base_url}/items/list?biblionumber=#{id}&login_userid=#{user}&login_password=#{password}"
      items_response = RestClient.get items_url
      items_response_body = items_response.body
      reserves_url = "#{base_url}/reserves/list?biblionumber=#{id}&login_userid=#{user}&login_password=#{password}"
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
    @display_info = []
    @edition = nil
    @has_enum = nil
    @biblio_call_number = nil

    if bib_xml.search('//record/datafield[@tag="095"]/subfield[@code="a"]').text.present?
      @biblio_call_number = bib_xml.search('//record/datafield[@tag="095"]/subfield[@code="a"]').text
    end

    # Create an author string, based on 100 and 700 fields and add it to display_info
    authors = []
    bib_xml.search('//record/datafield[@tag="100" or @tag="700"]').each do |author_field|
      author_name = create_author_name(author_field)
      authors << author_name if author_name.present?
    end
    @display_info[0] = authors.join(" ") if authors.any?

    # Create a string with place, edition and publication year, save it as orgin and add it to display_info.
    # First try with 260 field, if not available try with 264 field.

    if bib_xml.search('//record/datafield[@tag="260"]').text.present?
      field = bib_xml.search('//record/datafield[@tag="260"]').first
      @origin = create_origin(field)
    elsif bib_xml.search('//record/datafield[@tag="264" and @ind2="1"]').text.present?
      field = bib_xml.search('//record/datafield[@tag="264" and @ind2="1"]').first
      @origin = create_origin(field)
    end
    @display_info[1] = @origin if @origin.present?

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
                bib_xml.search('//record/datafield[@tag="245"]/subfield[@code="p"]').text].join(" ").strip

      @edition = bib_xml.search('//record/datafield[@tag="250"]/subfield[@code="a"]').text if bib_xml.search('//record/datafield[@tag="250"]/subfield[@code="a"]').text.present?
    end

    link_urls = bib_xml.search('//record/datafield[@tag="856"]/subfield[@code="u"]').map(&:text)
    if link_urls.any? {|url| url.include?("urn:nbn:se:gu:ub:kat57-") }
      @redirect_url = link_urls.find {|url| url.include?("urn:nbn:se:gu:ub:kat57-") }
    end

    @items = []
    @no_in_queue = 0
    borrowers = [];

    reserves = JSON.parse(reserves_data)["reserves"]
    item_list = JSON.parse(items_data)["items"]
    @complete_item_count = item_list.length
    item_list.each do |item_data|
      item = Item.new(biblio_id: self.id, rawdata: item_data, has_item_level_queue: self.has_item_level_queue)
      next if item.item_type.blank?
      next if item.sublocation_id.blank?
      next if item.masked?
      item.is_reserved = false
      reserves.each do |reserve|
        if reserve["itemnumber"].present?
          if reserve["itemnumber"].to_s == item.id.to_s
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

    # Get the library that have the highest number of items and set default queue library .
    location_list =  @items.map{|i|i.location_id}
    location_max_no_of_items = location_list.max_by{|l| location_list.count(l)}
    @default_queue_location = Location.find_by_id(location_max_no_of_items).pickup_location_id
  end

  def create_author_name author_field
  # Exclude the entries with ind2 eq to 2
    return nil if author_field['ind2'] == '2'
    name_parts = []
    name = author_field.search('subfield[@code="a"]').text if author_field.search('subfield[@code="a"]').text.present?
    # The name is in the form "Lastname, Firstname," split and rearrange to "Firstname Lastname"
    if name && name.include?(",")
      name_split = name.split(",").map(&:strip)
      name = "#{name_split[1]} #{name_split[0]}"
    end
    year = author_field.search('subfield[@code="d"]').text if author_field.search('subfield[@code="d"]').text.present?
    role_code = author_field.search('subfield[@code="4"]').text if author_field.search('subfield[@code="4"]').text.present?
    # Get role from marc relator code mapping
    role = Biblio.marc_relator_mapping(role_code) if role_code.present?
    name_parts << name if name.present?
    name_parts << year if year.present?
    name_parts << role if role.present?
    return name_parts.join(" ")
  end

  def self.marc_relator_mapping code
    mapping = {
      'ill' => 'illustratör',
      'pbl' => 'utgivare',
      'arr' => 'arrangör',
      'lyr' => 'sångtextförfattare',
      'cmp' => 'kompositör',
      'ctb' => 'bidragsgivare',
      'aui' => 'förordsförfattare',
      'art' => 'konstnär',
      'pht' => 'fotograf',
      'aut' => 'författare',
      'trl' => 'översättare',
      'edt' => 'redaktör',
      'hnr' => 'festskriftsföremål',
      'cov' => 'omslagsformgivare'
    }
    # If no mapping found, return empty string
    return mapping[code] || ''
  end

  def create_origin field
      a_field = field.search('subfield[@code="a"]').text if field.search('subfield[@code="a"]').text.present?
      b_field = []
      field.search('subfield[@code="b"]').each do |b|
        b_field << b.text if b.text.present?
      end
      c_field = field.search('subfield[@code="c"]').text if field.search('subfield[@code="c"]').text.present?
      # Remove any leading "[" and trailing "]" from c_field entries
      c_field = c_field.gsub(/^\[|\]$/, '') if c_field.present?
      origin_parts = []
      origin_parts << a_field if a_field.present?
      origin_parts << b_field.join(" ") if b_field.any?
      origin_parts << c_field if c_field.present?
      origin_parts.join(" ").strip
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
