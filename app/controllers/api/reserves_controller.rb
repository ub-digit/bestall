class Api::ReservesController < ApplicationController
  def create
    borrowernumber = params[:user_id]
    branchcode = params[:location_id]
    biblionumber = params[:biblio_id]
    itemnumber = params[:item_id]
    # add parameter loan_type
    loantype = params[:loan_type]

    # TODO use loantype, but with correct name as it appears in Koha.
    # TODO: Error handling
    # Check the parameters and return error if params are not correct

    reserve = Reserve.add(borrowernumber: borrowernumber, branchcode: branchcode, biblionumber: biblionumber, itemnumber: itemnumber)
    if reserve
      @response[:reserve] = reserve.as_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Error when creating a reserve")
    end
    render_json
  end
end
