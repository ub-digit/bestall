require 'open-uri'

class Api::SessionController < ApplicationController

  # Create a session, with a newly generated access token
  def create
    pp params
    if params[:cas_ticket] && params[:cas_service]
      username = cas_validate(params[:cas_ticket], params[:cas_service])
    elsif params[:username] && params[:password] && User.authenticate(params[:username], params[:password])
      username = params[:username]
    else
      error_msg(ErrorCodes::UNAUTHORIZED, "Invalid credentials")
      render_json
      return
    end

    if username
      user = User.find_by_username(username)
      if user
        access_token = AccessToken.generate_token(user)
        if access_token
          @response[:access_token] = access_token.token
          @response[:token_type] = "bearer"
          @response[:user] = user.as_json
        else
          error_msg(ErrorCodes::NOT_FOUND, "Error creating token.")
        end
      else
        error_msg(ErrorCodes::NOT_FOUND, "User not found in Koha: #{username}")
      end
    else
      error_msg(ErrorCodes::UNAUTHORIZED, "Invalid credentials")
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
      body = u.read
      doc = Nokogiri::XML(body)
      doc.remove_namespaces!
      username = doc.search('//serviceResponse/authenticationSuccess/user').text
      return username if not username.empty?
    end
  end
end
