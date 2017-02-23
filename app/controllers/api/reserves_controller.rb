class Api::ReservesController < ApplicationController
  before_action :validate_access

  def create
    borrowernumber = params[:reserve][:user_id]
    branchcode = params[:reserve][:location_id]
    biblionumber = params[:reserve][:biblio_id]
    itemnumber = params[:reserve][:item_id]
    loantype = params[:reserve][:loan_type_id]
    reservenotes = params[:reserve][:reserve_notes]

    error_msg(ErrorCodes::VALIDATION_ERROR, "user_id is required") if borrowernumber.blank?
    error_msg(ErrorCodes::VALIDATION_ERROR, "location_id is required") if branchcode.blank?
    error_msg(ErrorCodes::VALIDATION_ERROR, "biblio_id is required") if biblionumber.blank?
    if loantype.blank?
      error_msg(ErrorCodes::VALIDATION_ERROR, "loan_type_id is required")
    else
      reservenotes = 'loantype: ' + loantype + '%0A' + (reservenotes.present? ? reservenotes : '')
    end
    if @response[:errors].present?
      render_json
      return
    end

    # Check that requested user is same as current user
    user_id = borrowernumber.to_i
    currentuser_id = AccessToken.find_by_username(@current_username).user_id
    if user_id != currentuser_id
      error_msg(ErrorCodes::PERMISSION_ERROR, "Requested user must be same same as logged in user")
      render_json
      return
    end

    if @response[:errors].nil?
      result = Reserve.add(borrowernumber: borrowernumber, branchcode: branchcode, biblionumber: biblionumber, itemnumber: itemnumber, reservenotes: reservenotes)
      if result.class == Reserve
        @response[:reserve] = result.as_json
        render_json(201)
        return
      elsif result.class == Hash
        if result[:code] == 400
          error_msg(ErrorCodes::ERROR, result[:msg], result[:errors])
        end
        if result[:code] == 403
          error_msg(ErrorCodes::PERMISSION_ERROR, result[:msg], result[:errors])
        end
        if result[:code] == 404
          error_msg(ErrorCodes::REQUEST_ERROR, result[:msg], result[:errors])
        end
        if result[:code] == 500
          error_msg(ErrorCodes::SERVER_ERROR, result[:msg], result[:errors])
        end
      else
        error_msg(ErrorCodes::OBJECT_ERROR, "Error when creating a reserve")
      end
    end
    render_json
  end
end
