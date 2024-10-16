class Api::BibliosController < ApplicationController
  def show
    id = params[:id]
    # setting items_on_subscriptions to false will speed up response time by excluding item and reserve lists
    items_on_subscriptions = params[:items_on_subscriptions] || "false"
    biblio = Biblio.find_by_id id, {items_on_subscriptions: items_on_subscriptions}
    if biblio
      if biblio.can_be_borrowed || params[:force]
        @response[:biblio] = biblio.as_json({user_category_code: validate_token ? User.get_category_code(@current_username) : nil})
      else
        error_msg(ErrorCodes::FORBIDDEN, "Item not allowed for loan: #{params[:id]}", [{"code" => "CAN_NOT_BE_BORROWED", "detail" => "This item is not allowed for loan."}])
      end
    else
      error_msg(ErrorCodes::NOT_FOUND, "Item not found: #{params[:id]}", [{"code" => "ITEM_NOT_FOUND", "detail" => "The requested biblio record could not be found."}])
    end
    render_json
  end
end
