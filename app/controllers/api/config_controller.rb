class Api::ConfigController < Api::ApiController


	# Returns config data
	def show
		cas_url = APP_CONFIG['cas_url']
    registration_url = APP_CONFIG['registration_url']
		@response[:config] = {id: "1", casurl: cas_url, registrationurl: registration_url}
		render_json
	end
end
