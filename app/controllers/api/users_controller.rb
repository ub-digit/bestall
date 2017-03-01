class Api::UsersController < ApplicationController
  before_action :validate_access

  def current_user
    user = User.find_by_username(@current_username)
    if user
      if user.denied
        #compose error list of the reasons to why the user is denied
        error_list = Array.new
        error_list.push({"code" => "BANNED", "detail" => "User is banned."}) if user.banned
        error_list.push({"code" => "CARD_LOST", "detail" => "Users card has been reported as lost."}) if user.card_lost
        error_list.push({"code" => "FINES", "detail" => "Fines exceed maximum allowed amount."}) if user.fines
        error_list.push({"code" => "DEBARRED", "detail" => "User is debarred."}) if user.debarred
        error_list.push({"code" => "NO_ADDRESS", "detail" => "User has no address record."}) if user.no_address
        error_list.push({"code" => "EXPIRED", "detail" => "Card has expired."}) if user.expired


        error_list.push({"categorycode" => user.categorycode})
        error_msg(ErrorCodes::UNAUTHORIZED, "Access denied", error_list)
      else
        @response[:user] = user.as_json
      end
    else
      error_msg(ErrorCodes::NOT_FOUND, "Could not find user")
    end
    render_json
  end
end
