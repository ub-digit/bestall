class Api::ReservesController < ApplicationController
  def create
    borrowernumber = params[:borrowernumber]
    branchcode = params[:branchcode]
    biblionumber = params[:biblionumber]
    itemnumber = params[:itemnumber]
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
