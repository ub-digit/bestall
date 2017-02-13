class Api::BibliosController < ApplicationController
	def show
    id = params[:id]

    biblio = Biblio.find_by_id id
    if biblio
      @response[:biblio] = biblio.as_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Item not found: #{params[:id]}")
    end
    render_json
  end
end