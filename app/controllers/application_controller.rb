class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
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
      render json: @response, status: ErrorCodes.const_get(@response[:errors][:code])[:http_status]
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
  # Sets user according to token or api_key, or authenication error if fail
  def validate_access
    if !validate_token
      error_msg(ErrorCodes::UNAUTHORIZED, "User not valid")
      render_json
    end
  end

  # Validates token and sets user if token if valid
  def validate_token
    return false if @current_username
    token = get_token
    token.force_encoding('utf-8') if token
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.validated?
      @current_username = token_object.username
      return true
    else
      return false
    end
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
