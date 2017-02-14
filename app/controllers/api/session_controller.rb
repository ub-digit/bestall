require 'open-uri'

class Api::SessionController < ApplicationController

  # Create a session, with a newly generated access token
  def create
    user_force_authenticated = false # True if authentication is ticket based
    password = "dummy-not-used-with-cas"

    if params[:cas_ticket] && params[:cas_service]
      username = cas_validate(params[:cas_ticket], params[:cas_service])
      user_force_authenticated = true
      service = :cas
    else
      error_msg(ErrorCodes::AUTH_ERROR, "CAS ticket is mandatory.")
      render_json
    end

    user = User.find_by_username(username)
    if user
      token = user.authenticate(password, user_force_authenticated)
      if token
        @response[:user] = user.as_json
        @response[:access_token] = token
        @response[:token_type] = "bearer"
        render_json
        return
      else
        error_msg(ErrorCodes::AUTH_ERROR, "Invalid credentials")
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "User not found in Koha: #{params[:username]}")
    end
    render_json
  end


  def show
    @response = {}
    token = params[:id]
    extend_expire = true
    if params[:no_extend].present?
      extend_expire = false
    end
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.user.validate_token(token, extend_expire)
      @response[:user] = token_object.user.as_json
      @response[:access_token] = token
      @response[:token_type] = "bearer"
    else
      error_msg(ErrorCodes::SESSION_ERROR, "Invalid session")
    end
    render_json
  end

  private
  def cas_validate(ticket, service)
    casBaseUrl = APP_CONFIG['cas_url']
    casParams = {
      service: service,
      ticket: ticket
    }.to_param
    casValidateUrl = "#{casBaseUrl}/serviceValidate?#{casParams}"
    open(casValidateUrl) do |u|
      doc = Nokogiri::XML(u.read)
      doc.remove_namespaces!
      username = doc.search('//serviceResponse/authenticationSuccess/user').text
      return username if username
    end
  end
end
