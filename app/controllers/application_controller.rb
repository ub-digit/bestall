class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :setup

  # Setup global state for response
  def setup
    @response ||= {}
  end

  # Renders the response object as json with proper request status
  def render_json(status=200)
    # If successful, render given status
    if @response[:errors].nil?
      render json: @response, status: status
    else
      # If not successful, render with status from ErrorCodes module
      render json: @response, status: ErrorCodes.const_get(@response[:errors][:code])[:status]
    end
  end

  # Generates an error object from code, message and error list
  def error_msg(code=ErrorCodes::INTERNAL_SERVER_ERROR, detail="Unspecified error", errors = nil, data = nil)
    @response[:errors] = {
      code: code[:code],
      detail: detail,
      errors: errors,
      data: data
    }
  end

private
  def validate_access_or_apikey
    if !validate_apikey && !validate_token
      error_msg(ErrorCodes::UNAUTHORIZED, "User not valid")
      render_json
    end
  end

  # Sets user according to token or api_key, or authenication error if fail
  def validate_access
    if !validate_token
      error_msg(ErrorCodes::UNAUTHORIZED, "User not valid")
      render_json
    end
  end

  def validate_apikey
    apikey = params[:api_key]
    if apikey && apikey == APP_CONFIG['api_key']
      return true
    else
      return false
    end
  end

  # Validates token and sets user if token if valid
  def validate_token
    return true if @current_username
    current_user_from_header = request.headers['current-username']    # current_user_from_header can be userid, cardnumber or personalnumber, we need to always set current_username to username (cadnumber)
    @current_username = User.find_by_username(current_user_from_header).try(:username)
    return true if @current_username
    return false
  end

  # Returns mtoken from request headers or params[:token] if set
  def get_token
    if params.has_key?(:token) && params[:token] != ''
      return params[:token]
    end
    return nil if !request || !request.headers
    token_response = request.headers['Authorization']
    return nil if !token_response
    token_response[/^Token (.*)/,1]
  end
end
