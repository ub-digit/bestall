class Api::PrintController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    if !validate_key
      error_msg(ErrorCodes::UNAUTHORIZED, "API key not valid")
      render_json
      return
    end

    missing_field_list = missing_fields(params)
    if !missing_field_list.empty?
      error_msg(ErrorCodes::UNPROCESSABLE_ENTITY, "Missing mandatory fields: #{missing_field_list.join(', ')}")
      render_json
      return
    end

    obj = {}
    obj[:location] = params[:location] if params[:location].present?
    obj[:sublocation] = params[:sublocation] if params[:sublocation].present?
    obj[:sublocation_id] = params[:sublocation_id] if params[:sublocation_id].present?
    obj[:call_number] = params[:call_number] if params[:call_number].present?
    obj[:barcode] = params[:barcode] if params[:barcode].present?
    obj[:bibid] = params[:biblio_id] if params[:biblio_id].present?
    obj[:author] = params[:author] if params[:author].present?
    obj[:title] = params[:title] if params[:title].present?
    obj[:alt_title] = params[:alt_title] if params[:alt_title].present?
    obj[:volume] = params[:volume] if params[:volume].present?
    obj[:place] = params[:place] if params[:place].present?
    obj[:edition] = params[:edition] if params[:edition].present?
    obj[:serie] = params[:serie] if params[:serie].present?
    obj[:notes] = params[:notes] if params[:notes].present?
    obj[:description] = params[:description] if params[:description].present?
    obj[:loantype] = params[:loantype] if params[:loantype].present?
    obj[:extra_info] = params[:extra_info] if params[:extra_info].present?
    obj[:name] = params[:name] if params[:name].present?
    obj[:borrowernumber] = params[:borrowernumber] if params[:borrowernumber].present?
    obj[:pickup_location] = params[:pickup_location] if params[:pickup_location].present?

    pdf = Print.create_pdf(obj)

    @response[:print] = {}
    render_json(201)
  end

private
  def missing_fields params
    field_list = []
    field_list << "sublocation_id" if params[:sublocation_id].blank?
    # TBD Check other mandatory fields and add missing fields to list
    field_list
  end

  def validate_key
    return false if !params[:api_key]
    return false if !params[:api_key].eql?(APP_CONFIG['api_key'])
    return true
  end
end
