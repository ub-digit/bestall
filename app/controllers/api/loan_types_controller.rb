class Api::LoanTypesController < ApplicationController
  def index
    loan_types = LoanType.all
    @response[:loan_types] = loan_types.as_json
    render_json
  end
end
