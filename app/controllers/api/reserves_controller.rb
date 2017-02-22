class Api::ReservesController < ApplicationController
  def create
    borrowernumber = params[:user_id]
    branchcode = params[:location_id]
    biblionumber = params[:biblio_id]
    itemnumber = params[:item_id]
    loantype = params[:loan_type_id]
    reservenotes = params[:reserve_notes]

    error_msg(ErrorCodes::VALIDATION_ERROR, "user_id is required") if borrowernumber.blank?
    error_msg(ErrorCodes::VALIDATION_ERROR, "location_id is required") if branchcode.blank?
    error_msg(ErrorCodes::VALIDATION_ERROR, "biblio_id is required") if biblionumber.blank?
    if loantype.blank?
      error_msg(ErrorCodes::VALIDATION_ERROR, "loan_type_id is required")
    else
      reservenotes = 'loantype: ' + loantype + '%0A' + (reservenotes.present? ? reservenotes : '')
    end

    if @response[:errors].nil?
      result = Reserve.add(borrowernumber: borrowernumber, branchcode: branchcode, biblionumber: biblionumber, itemnumber: itemnumber, reservenotes: reservenotes)
      if result.class == Reserve
        @response[:reserve] = result.as_json
      elsif result.class == Hash
        if result[:code][:http_status] == 400
          error_msg(ErrorCodes::ERROR, result[:msg], result[:errors])
        end
        if result[:code][:http_status] == 403
          error_msg(ErrorCodes::PERMISSION_ERROR, result[:msg], result[:errors])
        end
        if result[:code][:http_status] == 404
          error_msg(ErrorCodes::REQUEST_ERROR, result[:msg], result[:errors])
        end

      else
        error_msg(ErrorCodes::OBJECT_ERROR, "Error when creating a reserve")
      end
    end

    render_json
  end
end
