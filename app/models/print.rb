require "prawn/measurement_extensions"
class Print
  def self.prepare_subscription_order(params, username)
    obj = {}
    obj[:subscription_info_text] = true
    obj[:borrowernumber] = params[:reserve][:user_id] if params[:reserve][:user_id].present?
    obj[:bibid] = params[:reserve][:biblio_id] if params[:reserve][:biblio_id].present?
    obj[:location] = params[:reserve][:subscription_location] if params[:reserve][:subscription_location].present?
    obj[:sublocation] = params[:reserve][:subscription_sublocation] if params[:reserve][:subscription_sublocation].present?
    obj[:sublocation_id] = params[:reserve][:subscription_sublocation_id] if params[:reserve][:subscription_sublocation_id].present?
    obj[:call_number] = params[:reserve][:subscription_call_number] if params[:reserve][:subscription_call_number].present?
    obj[:description] = params[:reserve][:subscription_notes] if params[:reserve][:subscription_notes].present?

    user_obj = User.find_by_username(username)
    obj[:name] = user_obj ? [user_obj.first_name, user_obj.last_name].compact.join(" ") : ''
    obj[:extra_info] = user_obj ? user_obj.attr_print : ''

    loan_type_obj = LoanType.find_by_id(params[:reserve][:loan_type_id].to_i)
    obj[:loantype] = loan_type_obj ? loan_type_obj.name_sv : ''

    pickup_location_obj = Location.find_by_id(params[:reserve][:location_id].to_i)
    obj[:pickup_location] = pickup_location_obj ? pickup_location_obj.name_sv : ''

    biblio_obj = Biblio.find_by_id(params[:reserve][:biblio_id])
    if biblio_obj
      obj[:title] = biblio_obj.title.squish if biblio_obj.title.present?
      obj[:place] = biblio_obj.origin if biblio_obj.origin.present?
      obj[:edition] = biblio_obj.edition if biblio_obj.edition.present?
    end

    obj
  end

  def self.print_segment(pdf, obj, start_cursor)
    # Right column (data)
    size = 9
    pdf.bounding_box([27.send(:mm), start_cursor], :width => 100.send(:mm)) do
      pdf.text "#{Time.now.strftime("%Y-%m-%d %H:%M")}", size: size, :align=>:right
      pdf.text "#{obj[:location]} #{obj[:sublocation]} ", size: size
    end
    end_of_location_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:call_number]} ", size: size
      pdf.text "#{obj[:barcode]} ", size: size
      pdf.text "#{obj[:bibid]} ", size: size
      pdf.text "#{obj[:author]} ", size: size
      pdf.text "#{obj[:title]} ", size: size
    end
    end_of_title_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:alt_title]} ", size: size
    end
    end_of_alt_title_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:volume]} ", size: size
      pdf.text "#{obj[:place]} ", size: size
    end
    end_of_place_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:edition]} ", size: size
      pdf.text "#{obj[:serie]} ", size: size
      pdf.text "#{obj[:description]} ", size: size
    end
    end_of_desc_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:loantype]} ", size: size
      pdf.text "#{obj[:extra_info]} ", size: size
    end
    end_of_extra_info_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:name]} ", size: size
      pdf.text "#{obj[:borrowernumber]} ", size: size
      pdf.text "#{obj[:pickup_location]} ", size: size
    end
    end_of_pickup_location_line_cursor = pdf.cursor

    # Left column (labels)
    pdf.bounding_box([0, start_cursor], :width => 25.send(:mm)) do
      pdf.text " ", size: size, :align=>:right
      pdf.text "PLACERING:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_location_line_cursor], :width => 25.send(:mm), font_size: size) do
      pdf.text "HYLLUPPST:", size: size, :align=>:right
      pdf.text "STRECKKOD:", size: size, :align=>:right
      pdf.text "BIBID:", size: size, :align=>:right
      pdf.text "FÖRF/INST:", size: size, :align=>:right
      pdf.text "TITEL:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_title_line_cursor], :width => 25.send(:mm), font_size: size) do
      pdf.text "DELTITEL:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_alt_title_line_cursor], :width => 25.send(:mm), font_size: size) do
      pdf.text "VOLYM:", size: size, :align=>:right
      pdf.text "ORT/../ÅR:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_place_line_cursor], :width => 25.send(:mm), font_size: size) do
      pdf.text "UPPLAGA:", size: size, :align=>:right
      pdf.text "SERIE:", size: size, :align=>:right
      pdf.text "BESKRIVNING:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_desc_line_cursor], :width => 25.send(:mm), font_size: size) do
      pdf.text "BEST.TYP:", size: size, :align=>:right
      pdf.text "SÄRSK.INFO:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_extra_info_line_cursor], :width => 25.send(:mm), font_size: size) do
      pdf.text "NAMN:", size: size, :align=>:right
      pdf.text "ID-NR:", size: size, :align=>:right
      pdf.text "HÄMTAS PÅ:", size: size, :align=>:right
    end

    pdf.bounding_box([0, end_of_extra_info_line_cursor], :width => 25.send(:mm), font_size: size) do
      pdf.text "NAMN:", size: size, :align=>:right
      pdf.text "ID-NR:", size: size, :align=>:right
      pdf.text "HÄMTAS PÅ:", size: size, :align=>:right
    end
    if obj[:subscription_info_text]
      pdf.bounding_box([0, end_of_pickup_location_line_cursor], :width => 100.send(:mm), font_size: size) do
        pdf.text "Lägg till en reservation på exemplaret och återlämna.", size: size, :style=>:bold
      end
    end
    return pdf
  end

  def self.create_pdf(obj)
    document = Prawn::Document.new :page_size=> 'A5', :margin=>[5.send(:mm), 10.send(:mm), 5.send(:mm), 10.send(:mm)]
    document.font_families.update("Roboto" => {:normal => "lib/fonts/Roboto-Regular.ttf", :bold => "lib/fonts/Roboto-Bold.ttf"})
    document.font "Roboto"

    pdf = print_segment(document, obj, document.cursor)
    pdf = print_segment(document, obj, 95.send(:mm))

    file_path = APP_CONFIG['file_path']
    sublocation_id = obj[:sublocation_id].to_i
    location_id = Sublocation.find_by_id(sublocation_id).location_id
    suffix = ""
    suffix = "_#{obj[:reserve_id]}" if obj[:reserve_id]

    pdf.render_file "#{file_path}/#{sublocation_id}_pr#{location_id}_#{Time.now.strftime("%Y%m%d%H%M%S")}_#{SecureRandom.hex}#{suffix}.pdf"

    return pdf
  end
end