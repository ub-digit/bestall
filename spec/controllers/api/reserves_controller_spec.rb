require 'rails_helper'

RSpec.describe Api::ReservesController, type: :controller do

  describe "get create" do
    before :each do
      WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xallowed&password=password&userid=username").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-allowed.xml"), :headers => {})
      @xallowed_token = AccessToken.generate_token(User.find_by_username('xallowed'))
    end

    context "for a valid reservation without token" do
      it "should return an authentication error" do
        post :create, params: {reserve: {user_id: 1, location_id: 10, biblio_id: 50, loan_type_id: 1}}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('AUTH_ERROR')
      end
    end

    context "for a valid reservation with an invalid token" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xdenied&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-denied.xml"), :headers => {})
        @xdenied_token = AccessToken.generate_token(User.find_by_username('xdenied'))
      end
      it "should return an permission error" do
        post :create, params: {reserve: {user_id: 1, location_id: 10, biblio_id: 50, loan_type_id: 1}, token: @xdenied_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('PERMISSION_ERROR')
      end
    end

    context "for a missing user_id" do
      it "should return an error object" do
        post :create, params: {reserve: {location_id: 10, biblio_id: 50, loan_type_id: 1}, token: @xallowed_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('VALIDATION_ERROR')
        expect(json['errors']['msg']).to eq('user_id is required')
      end
    end
    context "for a missing location_id" do
      it "should return an error object" do
        post :create, params: {reserve: {user_id: 1, biblio_id: 50, loan_type_id: 1}, token: @xallowed_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('VALIDATION_ERROR')
        expect(json['errors']['msg']).to eq('location_id is required')
      end
    end
    context "for a missing biblio_id" do
      it "should return an error object" do
        post :create, params: {reserve: {user_id: 1, location_id: 10, loan_type_id: 1}, token: @xallowed_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('VALIDATION_ERROR')
        expect(json['errors']['msg']).to eq('biblio_id is required')
      end
    end
    context "for a missing loan_type_id" do
      it "should return an error object" do
        post :create, params: {reserve: {user_id: 1, location_id: 10, biblio_id: 50}, token: @xallowed_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('VALIDATION_ERROR')
        expect(json['errors']['msg']).to eq('loan_type_id is required')
      end
    end

    context "for a valid reservation with a valid token" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/reserves/create?biblionumber=50&borrowernumber=1&branchcode=10&itemnumber=&password=password&reservenotes=loantype:%201%0A&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 201, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-success.xml"), :headers => {})
      end
      it "should return a reserve object" do
        post :create, params: {reserve: {user_id: 1, location_id: 10, biblio_id: 50, loan_type_id: 1}, token: @xallowed_token.token}
        expect(json['reserve']).to_not be nil
      end
    end
  end
end
