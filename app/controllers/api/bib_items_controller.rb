class Api::BibItemsController < ApplicationController
	def show
    id = params[:id]

    bib_item = BibItem.find_by_id id
    if bib_item
      @response[:bib_item] = bib_item.as_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Item not found: #{params[:id]}")
    end
    render_json
  end
end