require 'rails_helper'

RSpec.describe Api::ReservesController, type: :controller do

  describe "get create" do
    context "for a missing user_id" do
      it "should return an error object" do
        post :create, params: {location_id: 10, biblio_id: 50, loan_type_id: 1}
        expect(json['error']).to_not be nil
        expect(json['error']['code']).to eq('VALIDATION_ERROR')
        expect(json['error']['msg']).to eq('user_id is required')
      end
    end
    context "for a missing location_id" do
      it "should return an error object" do
        post :create, params: {user_id: 1, biblio_id: 50, loan_type_id: 1}
        expect(json['error']).to_not be nil
        expect(json['error']['code']).to eq('VALIDATION_ERROR')
        expect(json['error']['msg']).to eq('location_id is required')
      end
    end
    context "for a missing biblio_id" do
      it "should return an error object" do
        post :create, params: {user_id: 1, location_id: 10, loan_type_id: 1}
        expect(json['error']).to_not be nil
        expect(json['error']['code']).to eq('VALIDATION_ERROR')
        expect(json['error']['msg']).to eq('biblio_id is required')
      end
    end
    context "for a missing loan_type_id" do
      it "should return an error object" do
        post :create, params: {user_id: 1, location_id: 10, biblio_id: 50}
        pp json
        expect(json['error']).to_not be nil
        expect(json['error']['code']).to eq('VALIDATION_ERROR')
        expect(json['error']['msg']).to eq('loan_type_id is required')

        # error_msg(ErrorCodes::VALIDATION_ERROR, "user_id is required") if borrowernumber.blank?
        # error_msg(ErrorCodes::VALIDATION_ERROR, "location_id is required") if branchcode.blank?
        # error_msg(ErrorCodes::VALIDATION_ERROR, "biblio_id is required") if biblionumber.blank?
        # #error_msg(ErrorCodes::VALIDATION_ERROR, "item_id is required") if itemnumber.blank?
        # error_msg(ErrorCodes::VALIDATION_ERROR, "loan_type is required") if loantype.blank?
      end
    end

    context "for an invalid reservation" do
      before :each do
        WebMock.stub_request(
          :get, "http://koha.example.com/reserves/create?biblionumber=50&borrowernumber=&branchcode=10&itemnumber=&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 403, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-borrower-not-found.xml"), :headers => {})
      end
      it "should return an error object" do
        post :create, params: {user_id: 9, location_id: 10, biblio_id: 50}
        expect(json['error']).to_not be nil
      end
    end

    context "for a valid reservation" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/reserves/create?biblionumber=50&borrowernumber=1&branchcode=10&itemnumber=&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 201, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-success.xml"), :headers => {})
      end
      it "should return a reserve object" do
        post :create, params: {user_id: 1, location_id: 10, biblio_id: 50, loan_type_id: 1}
        expect(json['reserve']).to_not be nil
      end
    end
  end
end
