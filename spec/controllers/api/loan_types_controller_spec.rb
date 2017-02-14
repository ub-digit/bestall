require 'rails_helper'

RSpec.describe Api::LoanTypesController, type: :controller do

  describe "get index" do
    it "should return a list of loan type objects" do
      get :index

      expect(json['loan_types']).to be_truthy
      expect(json['loan_types']).to be_kind_of(Array)
    end
  end
end
