require "prawn/measurement_extensions"
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/prawn_outputter'

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
    obj[:firstname] = user_obj ? user_obj.first_name : ''
    obj[:lastname] = user_obj ? user_obj.last_name : ''
    obj[:cardnumber] = user_obj ? user_obj.cardnumber : ''
    obj[:categorycode] = user_obj ? user_obj.user_category : ''
    obj[:extra_info] = user_obj ? user_obj.attr_print : ''

    loan_type_obj = LoanType.find_by_id(params[:reserve][:loan_type_id].to_i)
    obj[:loantype] = loan_type_obj ? loan_type_obj.name_sv : ''

    # Location and pickup location may differ, get pickup location from the Location object
    pickup_location_id = Location.find_by_id(params[:reserve][:location_id].to_i).pickup_location_id
    obj[:pickup_location] = Location.find_by_id(pickup_location_id).name_sv
    obj[:pickup_location_id] = pickup_location_id

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
    right_column_left_margin = 33.send(:mm)
    right_column_width = 100.send(:mm)
    left_column_width = 31.send(:mm)

    pdf.bounding_box([right_column_left_margin, start_cursor], :width => 100.send(:mm)) do
      pdf.text "#{Time.now.strftime("%Y-%m-%d %H:%M")}", size: size, :align=>:right
    end
    end_of_timestamp_line_cursor = pdf.cursor
    pdf.bounding_box([right_column_left_margin, pdf.cursor], :width => right_column_width) do
      pdf.text "#{obj[:location]} #{obj[:sublocation]} ", size: size
    end
    end_of_location_line_cursor = pdf.cursor
    pdf.bounding_box([right_column_left_margin, pdf.cursor], :width => right_column_width) do
      pdf.text "#{obj[:call_number]} ", size: size
    end
    end_of_call_number_line_cursor = pdf.cursor
    pdf.bounding_box([right_column_left_margin, pdf.cursor], :width => right_column_width) do
      pdf.text "#{obj[:barcode]} ", size: size
      pdf.text "#{obj[:bibid]} ", size: size
      pdf.text "#{obj[:author]} ", size: size
      pdf.text "#{Print.truncate(obj[:title], 200)} ", size: size
    end
    end_of_title_line_cursor = pdf.cursor
    pdf.bounding_box([right_column_left_margin, pdf.cursor], :width => right_column_width) do
      pdf.text "#{Print.truncate(obj[:alt_title], 200)} ", size: size
    end
    end_of_alt_title_line_cursor = pdf.cursor
    pdf.bounding_box([right_column_left_margin, pdf.cursor], :width => right_column_width) do
      pdf.text "#{obj[:volume]} ", size: size
      pdf.text "#{Print.truncate(obj[:place], 100)} ", size: size
    end
    end_of_place_line_cursor = pdf.cursor
    pdf.bounding_box([right_column_left_margin, pdf.cursor], :width => right_column_width) do
      pdf.text "#{obj[:edition]} ", size: size
      pdf.text "#{Print.truncate(obj[:serie], 100)} ", size: size
    end
    end_of_serie_line_cursor = pdf.cursor
    pdf.bounding_box([right_column_left_margin, pdf.cursor], :width => right_column_width) do
      pdf.text "#{Print.truncate(obj[:description], 200)} ", size: size
    end
    end_of_desc_line_cursor = pdf.cursor
    pdf.bounding_box([right_column_left_margin, pdf.cursor], :width => right_column_width) do
      pdf.text "#{obj[:loantype]} ", size: size
      pdf.text "#{Print.truncate(obj[:extra_info], 200)} ", size: size
    end
    end_of_extra_info_line_cursor = pdf.cursor
    pdf.bounding_box([right_column_left_margin, pdf.cursor], :width => right_column_width) do
      if APP_CONFIG['show_pickup_code']
        pdf.text "#{User.create_pickup_code(obj)} ", size: size
      else
        pdf.text "#{User.create_name(obj)} ", size: size
      end
      pdf.text "#{obj[:borrowernumber]} ", size: size
      pdf.text "#{obj[:pickup_location]} ", size: size
    end
    end_of_pickup_location_line_cursor = pdf.cursor

    # Left column (labels)
    pdf.bounding_box([0, start_cursor], :width => 31.send(:mm)) do
      pdf.text " ", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_timestamp_line_cursor], :width => left_column_width, font_size: size) do
      pdf.text "PLACERING:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_location_line_cursor], :width => left_column_width, font_size: size) do
      pdf.text "HYLLUPPST:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_call_number_line_cursor], :width => left_column_width, font_size: size) do
      pdf.text "STRECKKOD:", size: size, :align=>:right
      pdf.text "BIBID:", size: size, :align=>:right
      pdf.text "FÖRF/INST:", size: size, :align=>:right
      pdf.text "TITEL:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_title_line_cursor], :width => left_column_width, font_size: size) do
      pdf.text "DELTITEL:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_alt_title_line_cursor], :width => left_column_width, font_size: size) do
      pdf.text "VOLYM:", size: size, :align=>:right
      pdf.text "ORT/../ÅR:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_place_line_cursor], :width => left_column_width, font_size: size) do
      pdf.text "UPPLAGA:", size: size, :align=>:right
      pdf.text "SERIE:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_serie_line_cursor], :width => left_column_width, font_size: size) do
      pdf.text "BESKRIVNING:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_desc_line_cursor], :width => left_column_width, font_size: size) do
      pdf.text "BESTÄLLNINGSTYP:", size: size, :align=>:right
      pdf.text "SÄRSKILD INFO:", size: size, :align=>:right
    end
    pdf.bounding_box([0, end_of_extra_info_line_cursor], :width => left_column_width, font_size: size) do
      if APP_CONFIG['show_pickup_code']
        pdf.text "AVHÄMTNINGSKOD:", size: size, :align=>:right
      else
        pdf.text "NAMN:", size: size, :align=>:right
      end
      pdf.text "LÅNTAGARNUMMER:", size: size, :align=>:right
      pdf.text "HÄMTAS PÅ:", size: size, :align=>:right
    end

    if obj[:subscription_info_text]
      pdf.bounding_box([0, end_of_pickup_location_line_cursor], :width => right_column_width, font_size: size) do
        pdf.text "Lägg till en reservation på exemplaret och återlämna.", size: size, :style=>:bold
      end
    end

    if obj[:barcode]
      barcode  = Barby::Code128B.new("#{obj[:barcode]}")
      barcode.annotate_pdf(pdf, {:x => 55.send(:mm), :y => start_cursor - 93.send(:mm), :height => 8.send(:mm)})
      pdf.bounding_box([55.send(:mm), start_cursor - 93.send(:mm)], :width => 30.send(:mm),  height: 5.send(:mm), :align=>:right) do
        pdf.text obj[:barcode], size: 7
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

  def self.truncate text, maxlength
    return "" if text.nil?
    return text if text.length < maxlength
    return text[0..maxlength].strip + "..."
  end
end