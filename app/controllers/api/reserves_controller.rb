class Api::ReservesController < ApplicationController
  def create
    borrowernumber = params[:borrower_number]
    branchcode = params[:location_id]
    biblionumber = params[:biblio_id]
    itemnumber = params[:item_id]
    #TODO: Error handling

    reserve = Reserve.add(borrowernumber: borrowernumber, branchcode: branchcode, biblionumber: biblionumber, itemnumber: itemnumber)
    if reserve
      @response[:reserve] = reserve.as_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Error when creating a reserve")
    end
    render_json
  end
end
