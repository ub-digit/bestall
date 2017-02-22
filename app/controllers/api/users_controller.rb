class Api::UsersController < ApplicationController
  before_action :validate_access

  def current_user
    user = User.find_by_username(@current_username)
    if user
      if user.denied
        error_msg(ErrorCodes::PERMISSION_ERROR, "Access denied")
      else
        @response[:user] = user.as_json
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find user")
    end
    render_json
  end
end
