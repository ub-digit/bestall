require 'open-uri'

class Api::SessionController < ApplicationController

  # Create a session, with a newly generated access token
  def create
    if params[:code]
      uri = 'https://github.com/login/oauth/access_token'
      body = {
        "client_id" => APP_CONFIG['oauth2']['client_id'],
        "client_secret" => APP_CONFIG['oauth2']['client_secret'],
        "code" => params[:code]
      }
      # TODO: Don't think keyword args as headers work for this version of Net::HTTP
      # (seems to work anyway though)
      response = Net::HTTP.post(
        URI(uri),
        body.to_json,
        'Content-type' => 'application/json',
        'Accept' => 'application/json'
      )
      case response
        when Net::HTTPSuccess then
          json_response = JSON.parse(response.body)
          if json_response["access_token"]
            token = json_response["access_token"]
            uri = URI('https://api.github.com/user')
            response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
              request = Net::HTTP::Get.new(uri)
              request['Accept'] = 'application/vnd.github+json'
              request['Authorization'] = "Bearer #{token}"
              request['X-GitHub-Api-Version'] = '2022-11-28'
              response = http.request(request)
              response
            }
            case response
              when Net::HTTPSuccess then
                json_response = JSON.parse(response.body)
                if json_response["login"]
                  authenticated_user_response(json_response["login"])
                else
                  # This should really never happen
                  error_msg(ErrorCodes::UNAUTHORIZED, "Invalid user data")
                end
              else
                error_msg(ErrorCodes::UNAUTHORIZED, "User request failed")
              end
          else
            error = json_response["error"] ? json_response["error"] : "Unknown error"
            error_msg(ErrorCodes::UNAUTHORIZED, error)
          end
        else
          error_msg(ErrorCodes::UNAUTHORIZED, "OAuth request failed")
        end
    elsif params[:username] && params[:password]
      if User.authenticate(params[:username], params[:password])
        authenticated_user_response(params[:username])
      else
        error_msg(ErrorCodes::UNAUTHORIZED, "Invalid credentials")
      end
    else
      error_msg(ErrorCodes::UNAUTHORIZED, "Missing parameters")
    end
    render_json
  end

  private
  def authenticated_user_response(username)
    user = User.find_by_username(username)
    if user
      access_token = AccessToken.generate_token(user)
      if access_token
        @response[:access_token] = access_token.token
        @response[:token_type] = "bearer"
        @response[:user] = user.as_json
      else
        error_msg(ErrorCodes::INTERNAL_SERVER_ERROR, "Error creating token")
      end
    else
      error_msg(ErrorCodes::UNAUTHORIZED, "User not found in Koha: #{username}")
    end
  end
end
