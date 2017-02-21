class Api::UsersController < ApplicationController

  def current_user

    user = {id: 1234, username: "xaccount", first_name: "Magnus", last_name: "Kull"}

    @response[:user] = user
    render_json

  end
end
