class Api::ConfigController < Api::ApiController 


	# Returns cas_url if it is defined
	def cas_url
		url = APP_CONFIG['cas_url']
		@response[:config] = {id: "1", casurl: url}
		render_json
	end
end
