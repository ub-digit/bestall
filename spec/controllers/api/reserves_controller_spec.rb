require 'rails_helper'

RSpec.describe Api::ReservesController, type: :controller do

  describe "get create" do
    context "for a missing user_id" do
      it "should return an error object" do
        post :create, params: {location_id: 10, biblio_id: 50, loan_type: 1}
        expect(json['error']).to_not be nil
      end
    end
    context "for a missing location_id" do
      it "should return an error object" do
        post :create, params: {user_id: 1, biblio_id: 50, loan_type: 1}
        expect(json['error']).to_not be nil
      end
    end
    context "for a missing biblio_id" do
      it "should return an error object" do
        post :create, params: {user_id: 1, location_id: 10, loan_type: 1}
        expect(json['error']).to_not be nil
      end
    end
    context "for a missing loan_type" do
      it "should return an error object" do
        post :create, params: {user_id: 1, location_id: 10, biblio_id: 50}
        expect(json['error']).to_not be nil
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
        post :create, params: {user_id: 1, location_id: 10, biblio_id: 50, loan_type: 1}
        expect(json['reserve']).to_not be nil
      end
    end
  end
end
