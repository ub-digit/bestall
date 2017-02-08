class Api::LocationController < ApplicationController
	def index
		@response[:locations] = [{id: "1", name_sv: "Plats 1", name_en: "Location 1"}, {id: "2", name_sv: "Plats 2", name_en: 'Location 2'}]
		render_json
	end 
end
