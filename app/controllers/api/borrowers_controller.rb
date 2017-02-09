class Api::BorrowersController < ApplicationController
  def show
    userid = params[:id]
    borrower = Borrower.find_by_userid userid
    if borrower
      @response[:borrower] = borrower.as_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Borrower not found: #{params[:userid]}")
    end
    render_json
  end
end