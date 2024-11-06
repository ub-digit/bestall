require 'open-uri'

class Api::SessionController < ApplicationController

  def create
    if params[:code]
      body = {
        "client_id" => APP_CONFIG['oauth2']['client_id'],
        "client_secret" => APP_CONFIG['oauth2']['client_secret'],
        "code" => params[:code]
      }
      token_uri = URI(APP_CONFIG['oauth2']['token_endpoint'])

      if APP_CONFIG['oauth2']['provider'] == 'gu'
        authenticate_by_gu(body, token_uri)
      elsif APP_CONFIG['oauth2']['provider'] == 'github'
        authenticate_by_github(body, token_uri)
      else
        error_msg(ErrorCodes::INTERNAL_SERVER_ERROR, "Unknown OAuth2 provider")
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
  def authenticate_by_gu(body, token_uri)
    additional_body = {
      "grant_type" => "authorization_code",
      "redirect_uri" => "https://" + APP_CONFIG['frontend_hostname'] + "/torii/redirect.html"
    }
    body = body.merge(additional_body)

    http = Net::HTTP.new(token_uri.host, token_uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(token_uri.request_uri)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request.set_form_data(body)
    response = http.request(request)

    case response
    when Net::HTTPSuccess then
      begin
        json_response = JSON.parse(response.body)
      rescue JSON::ParserError
        error_msg(ErrorCodes::UNAUTHORIZED, "Invalid JSON response")
        return
      end
      if json_response["id_token"]
        token = json_response["id_token"]
        begin
          # Handle token as a JWT, decode it and extract the username
          decoded_token = JWT.decode(token, nil, false)
          username = decoded_token.first["account"]
          authenticated_user_response(username)
        rescue JWT::DecodeError
          error_msg(ErrorCodes::UNAUTHORIZED, "Invalid token")
        end
      else
        error_msg(ErrorCodes::UNAUTHORIZED, "Invalid data")
      end
    else
      error_msg(ErrorCodes::UNAUTHORIZED, "OAuth request failed")
    end
  end

  def authenticate_by_github(body, token_uri)
    # TODO: Don't think keyword args as headers work for this version of Net::HTTP
    # (seems to work anyway though)
    response = Net::HTTP.post(
      token_uri,
      body.to_json,
      'Content-type' => 'application/json',
      'Accept' => 'application/json'
    )

    case response
    when Net::HTTPSuccess then
      begin
        json_response = JSON.parse(response.body)
      rescue JSON::ParserError
        error_msg(ErrorCodes::UNAUTHORIZED, "Invalid JSON response")
        return
      end
      if json_response["access_token"]
        token = json_response["access_token"]
        uri = URI(APP_CONFIG['oauth2']['user_endpoint'])
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
            begin
              json_response = JSON.parse(response.body)
            rescue JSON::ParserError
              error_msg(ErrorCodes::UNAUTHORIZED, "Invalid JSON response")
              return
            end
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
        error = json_response["error_description"] ? json_response["error_description"] : "Unknown error"
        error_msg(ErrorCodes::UNAUTHORIZED, error)
      end
    else
      error_msg(ErrorCodes::UNAUTHORIZED, "OAuth request failed")
    end
  end

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
