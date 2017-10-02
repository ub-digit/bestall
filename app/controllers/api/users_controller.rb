class Api::UsersController < ApplicationController
  before_action :validate_access

  def current_user
    biblio_id = params[:biblio]
    if biblio_id.present?
      biblio = Biblio.find_by_id biblio_id
    else
      biblio = nil
    end

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
        user_data = {"user_category" => user.user_category}
        user_data["fines_amount"] = user.fines_amount if user.fines
        error_msg(ErrorCodes::FORBIDDEN, "Access denied", error_list, user_data)
      elsif biblio && biblio.has_biblio_level_queue && user.has_borrowed_item?(biblio_id)
        error_list = Array.new
        error_list.push({"code" => "ALREADY_BORROWED", "detail" => "User has already borrowed an item of this biblio."})
        user_data = {"user_category" => user.user_category}
        error_msg(ErrorCodes::FORBIDDEN, "Access denied", error_list, user_data)
      elsif biblio && biblio.has_biblio_level_queue && user.has_reserved_item?(biblio_id)
        error_list = Array.new
        error_list.push({"code" => "ALREADY_RESERVED", "detail" => "User has already ordered or is queued for this title."})
        user_data = {"user_category" => user.user_category}
        error_msg(ErrorCodes::FORBIDDEN, "Access denied", error_list, user_data)
      else
        @response[:user] = user.as_json
      end
    else
      error_msg(ErrorCodes::NOT_FOUND, "Could not find user")
    end
    render_json
  end
end
