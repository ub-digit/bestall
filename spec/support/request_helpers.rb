module Requests
  module JsonHelpers
    def json
      unless @last_response_body === response.body
        @json = nil
      end
      @last_response_body = response.body
      @json ||= JSON.parse(response.body)
    end
  end

end
