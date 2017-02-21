class Api::ReservesController < ApplicationController
  def create
    borrowernumber = params[:user_id]
    branchcode = params[:location_id]
    biblionumber = params[:biblio_id]
    itemnumber = params[:item_id]
    loantype = params[:loan_type]

    error_msg(ErrorCodes::VALIDATION_ERROR, "user_id is required") if borrowernumber.blank?
    error_msg(ErrorCodes::VALIDATION_ERROR, "location_id is required") if branchcode.blank?
    error_msg(ErrorCodes::VALIDATION_ERROR, "biblio_id is required") if biblionumber.blank?
    #error_msg(ErrorCodes::VALIDATION_ERROR, "item_id is required") if itemnumber.blank?
    error_msg(ErrorCodes::VALIDATION_ERROR, "loan_type is required") if loantype.blank?

    if @response[:error].nil?
      reserve = Reserve.add(borrowernumber: borrowernumber, branchcode: branchcode, biblionumber: biblionumber, itemnumber: itemnumber)
      if reserve
        @response[:reserve] = reserve.as_json
      else
        error_msg(ErrorCodes::OBJECT_ERROR, "Error when creating a reserve")
      end
    end

    render_json
  end
end
