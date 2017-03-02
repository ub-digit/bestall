class Api::BibliosController < ApplicationController
	def show
    id = params[:id]

    biblio = Biblio.find_by_id id
    if biblio
			if biblio.can_be_borrowed
      	@response[:biblio] = biblio.as_json
			else
				error_msg(ErrorCodes::FORBIDDEN, "Item not allowed for loan: #{params[:id]}")
			end
    else
      error_msg(ErrorCodes::NOT_FOUND, "Item not found: #{params[:id]}")
    end
    render_json
  end
end
