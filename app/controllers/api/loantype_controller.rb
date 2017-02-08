class Api::LoantypeController < ApplicationController
	def index 
		@response[:loantypes] = [{id: 1, name_sv: 'Hemlån', name_en: 'Homeloan'}, {id: 2, name_sv: 'Bortlån', name_en: 'Goneloan'}]
		render_json
	end 
end
