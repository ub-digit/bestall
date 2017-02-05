class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :setup

  # Setup global state for response
  def setup
    @response ||= {}
  end

  # Renders the response object as json with proper request status
  def render_json(status=200)
    # If successful, render given status
    if @response[:error].nil?
      render json: @response, status: status
    else
      # If not successful, render with status from ErrorCodes module
      render json: @response, status: ErrorCodes.const_get(@response[:error][:code])[:http_status]
    end
  end

  # Generates an error object from code, message and error list
  def error_msg(code=ErrorCodes::ERROR, msg="", error_list = nil)
    @response[:error] = {code: code[:code], msg: msg, errors: error_list}
  end
end
