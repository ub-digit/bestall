class Api::LocationsController < ApplicationController
	def index
		locations = Location.all
		@response[:locations] = locations.as_json
		render_json
	end
end
