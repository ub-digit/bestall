class Api::LibrisController < ApplicationController
  def index
    librisid = params[:Bib_ID]
    sigel = params[:BIBL]
    bibid =  get_bibid librisid

    items_xml = ""
    if bibid.present?
      location = sigel ? (get_location_id sigel) : nil
      biblio = Biblio.find_by_id bibid, {items_on_subscriptions: false}
      if biblio
        biblio.items.each_with_index do |item, index|
          if location.nil? || location == item.location_id.to_i
            items_xml << print_item(item, index)
          end
        end
      end
    end
    xml_document = print_document items_xml
    render xml: xml_document
  end

  def get_bibid librisid
    return nil if librisid.blank?
    base_url = APP_CONFIG['koha']['base_url']
    user =  APP_CONFIG['koha']['user']
    password =  APP_CONFIG['koha']['password']
    url = "#{base_url}/librisid2bibid/?librisid=#{librisid}&userid=#{user}&password=#{password}"
    response = RestClient.get url
    bibid = JSON.parse(response.body)["bibid"]
    return nil if bibid.blank?
    return bibid
  end

  def print_item item, index
    xml = ""
    xml << "<Item>"
    xml << "<Item_No>#{index + 1}</Item_No>"
    xml << "<UniqueItem_ID>#{item.id}</UniqueItem_ID>"
    xml << "<Location>#{item.location_name_sv}</Location>"
    xml << "<Call_No>#{item.item_call_number}</Call_No>"
    xml << "<Status>#{get_status item.status}</Status>"
    xml << "<Loan_Policy>#{get_loan_policy item.item_type}</Loan_Policy>"
    if item.status == "LOANED" && item.due_date
      xml << "<Status_Date_Description>Åter:</Status_Date_Description>"
      xml << "<Status_Date>#{Time.parse(item.due_date).strftime("%Y-%m-%d")}</Status_Date>"
   end
    xml << "</Item>"
  end

  def print_document items_xml
    "<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?>
    <Item_Information xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"http://appl.libris.kb.se/LIBRISItem.xsd\">
    #{items_xml}
    </Item_Information>"
  end

  def get_loan_policy item_type
    case item_type.to_i
    when 1, 3, 18
      return "Hemlån"
    when 8
      return "Ej hemlån"
    when 2, 19, 21
      return "Ej fjärrlån"
    when 4, 5, 6, 9, 10, 11, 20, 22, 23
      return "Tidskrift"
    when 7, 12, 13, 14, 15, 16
      return "Utlånas ej"
    when 17
      return "Mikrofilm"
    else
      return ""
    end
  end

  def get_status code
    return "Utlånad" if code == "LOANED"
    return "Väntar på avhämtning" if code == "WAITING"
    return "Under transport" if code == "IN_TRANSIT"
    return "Reserverad" if code == "RESERVED"
    return "Försenad" if code == "DELAYED"
    return "Ej på plats" if code == "NOT_IN_PLACE"
    return "Under inköp" if code == "DURING_ACQUISITION"
    "Tillgänglig"
  end

  def get_location_id sigel
    return 40 if sigel == "Gm"
    return 44 if sigel == "G"
    return 47 if sigel == "Gp"
    return 48 if sigel == "Ge"
    return 42 if sigel == "Gk"
    return 43 if sigel == "Gb"
    return 49 if sigel == "Gg"
    return 50 if sigel == "Gcl"
    return 60 if sigel == "Ghdk"
    return 62 if sigel == "Gumu"
    nil
  end
end
