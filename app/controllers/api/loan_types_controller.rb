class Api::LoanTypesController < ApplicationController
  def index
    params[:current_user] ||= {}
    params[:current_item] ||= {}
    pp params[:current_user]
    category_code = params[:current_user][:categorycode] || ""
    item_type = params[:current_item][:item_type] || ""
    status_limitation = params[:current_item][:status_limitation] || ""
    attr_orderpermission = params[:current_user][:attr_orderpermission] || ""
    # Use the parameters to determine which loan types to return
    loan_types = LoanType.where(category_code: category_code, item_type: item_type, status_limitation: status_limitation, attr_orderpermission: attr_orderpermission)
    @response[:loan_types] = loan_types.as_json
    render_json
  end
end
