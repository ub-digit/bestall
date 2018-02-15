require "prawn/measurement_extensions"
class Print
  def self.prepare_subscription_order(params, username)
    obj = {}
    obj[:borrowernumber] = params[:reserve][:user_id] if params[:reserve][:user_id].present?
    obj[:bibid] = params[:reserve][:biblio_id] if params[:reserve][:biblio_id].present?
    obj[:location] = params[:reserve][:subscription_location] if params[:reserve][:subscription_location].present?
    obj[:sublocation] = params[:reserve][:subscription_sublocation] if params[:reserve][:subscription_sublocation].present?
    obj[:sublocation_id] = params[:reserve][:subscription_sublocation_id] if params[:reserve][:subscription_sublocation_id].present?
    obj[:call_number] = params[:reserve][:subscription_call_number] if params[:reserve][:subscription_call_number].present?
    obj[:notes] = params[:reserve][:subscription_notes] if params[:reserve][:subscription_notes].present?

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
    pdf.bounding_box([27.send(:mm), start_cursor], :width => 100.send(:mm)) do
      pdf.text "#{Time.now.strftime("%Y-%m-%d %H:%M")}", :size=>8, :align=>:right
      pdf.text "#{obj[:location]} #{obj[:sublocation]} ", :size=>8
    end
    end_of_location_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:call_number]} ", :size=>8
      pdf.text "#{obj[:barcode]} ", :size=>8
      pdf.text "#{obj[:bibid]} ", :size=>8
      pdf.text "#{obj[:author]} ", :size=>8
      pdf.text "#{obj[:title]} ", :size=>8
    end
    end_of_title_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:alt_title]} ", :size=>8
    end
    end_of_alt_title_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:volume]} ", :size=>8
      pdf.text "#{obj[:place]} ", :size=>8
    end
    end_of_place_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:edition]} ", :size=>8
      pdf.text "#{obj[:serie]} ", :size=>8
      pdf.text "#{obj[:notes]} ", :size=>8
    end
    end_of_msg_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:description]} ", :size=>8
    end
    end_of_desc_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:loantype]} ", :size=>8
      pdf.text "#{obj[:extra_info]} ", :size=>8
    end
    end_of_extra_info_line_cursor = pdf.cursor
    pdf.bounding_box([27.send(:mm), pdf.cursor], :width => 100.send(:mm)) do
      pdf.text "#{obj[:name]} ", :size=>8
      pdf.text "#{obj[:borrowernumber]} ", :size=>8
      pdf.text "#{obj[:pickup_location]} ", :size=>8
      pdf.text "#{(Time.now + 7.days).strftime("%Y-%m-%d")}", :size=>8, :align=>:right
    end

    # Left column (labels)
    pdf.bounding_box([0, start_cursor], :width => 25.send(:mm)) do
      pdf.text " ", :size=>8, :align=>:right
      pdf.text "PLACERING:", :size=>8, :align=>:right
    end
    pdf.bounding_box([0, end_of_location_line_cursor], :width => 25.send(:mm), :font_size=>8) do
      pdf.text "HYLLUPPST:", :size=>8, :align=>:right
      pdf.text "STRECKKOD:", :size=>8, :align=>:right
      pdf.text "BIBID:", :size=>8, :align=>:right
      pdf.text "FÖRF/INST:", :size=>8, :align=>:right
      pdf.text "TITEL:", :size=>8, :align=>:right
    end
    pdf.bounding_box([0, end_of_title_line_cursor], :width => 25.send(:mm), :font_size=>8) do
      pdf.text "DELTITEL:", :size=>8, :align=>:right
    end
    pdf.bounding_box([0, end_of_alt_title_line_cursor], :width => 25.send(:mm), :font_size=>8) do
      pdf.text "VOLYM:", :size=>8, :align=>:right
      pdf.text "ORT/../ÅR:", :size=>8, :align=>:right
    end
    pdf.bounding_box([0, end_of_place_line_cursor], :width => 25.send(:mm), :font_size=>8) do
      pdf.text "UPPLAGA:", :size=>8, :align=>:right
      pdf.text "SERIE:", :size=>8, :align=>:right
      pdf.text "MEDD:", :size=>8, :align=>:right
    end
    pdf.bounding_box([0, end_of_msg_line_cursor], :width => 25.send(:mm), :font_size=>8) do
      pdf.text "BESKRIVN:", :size=>8, :align=>:right
    end
    pdf.bounding_box([0, end_of_desc_line_cursor], :width => 25.send(:mm), :font_size=>8) do
      pdf.text "BEST.TYP:", :size=>8, :align=>:right
      pdf.text "SÄRSK.INFO:", :size=>8, :align=>:right
    end
    pdf.bounding_box([0, end_of_extra_info_line_cursor], :width => 25.send(:mm), :font_size=>8) do
      pdf.text "NAMN:", :size=>8, :align=>:right
      pdf.text "ID-NR:", :size=>8, :align=>:right
      pdf.text "HÄMTAS PÅ:", :size=>8, :align=>:right
      pdf.text "HÄMTAS SENAST:", :size=>8, :align=>:right
    end

    return pdf
  end

  def self.create_pdf(obj)
    document = Prawn::Document.new :page_size=> 'A5', :margin=>[5.send(:mm), 10.send(:mm), 5.send(:mm), 10.send(:mm)]
    pdf = print_segment(document, obj, document.cursor)
    pdf = print_segment(document, obj, 95.send(:mm))

    file_path = APP_CONFIG['file_path']
    sublocation_id = obj[:sublocation_id].to_i
    location_id = Sublocation.find_by_id(sublocation_id).location_id
    pdf.render_file "#{file_path}/#{sublocation_id}_pr#{location_id}_#{Time.now.strftime("%Y%m%d%H%M%S")}_#{SecureRandom.hex}.pdf"

    return pdf
  end
end