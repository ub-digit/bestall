class Api::PickupLocationsController < ApplicationController
  def index    
    record_type = params[:record_type] || ""     
    params[:current_user] ||= {}
    params[:current_item] ||= {}
    params[:current_subscription] ||= {}
    # Use the parameters to determine which pickup locations to return
    pickup_locations = Location.where(record_type: record_type, current_user: params[:current_user], current_item: params[:current_item], current_subscription: params[:current_subscription])
    pp pickup_locations
    @response[:locations] = pickup_locations.as_json(include_sublocations: false)
    render_json
  end
end
