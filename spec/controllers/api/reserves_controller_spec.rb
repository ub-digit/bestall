require 'rails_helper'

RSpec.describe Api::ReservesController, type: :controller do

  describe "create" do
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
        expect(json['errors']['code']).to eq('UNAUTHORIZED')
      end
    end

    context "for a valid reservation with an invalid token" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xdenied&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-denied.xml"), :headers => {})
        @xdenied_token = AccessToken.generate_token(User.find_by_username('xdenied'))
      end
      it "should return an permission error" do
        post :create, params: {reserve: {user_id: 1, location_id: 10, biblio_id: 50, loan_type_id: 1}, token: @xdenied_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('UNAUTHORIZED')
      end
    end

    context "for a missing user_id" do
      it "should return an error object" do
        post :create, params: {reserve: {location_id: 10, biblio_id: 50, loan_type_id: 1}, token: @xallowed_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('UNPROCESSABLE_ENTITY')
        expect(json['errors']['errors'][0]['detail']).to eq('Required user_id is missing.')
      end
    end
    context "for a missing location_id" do
      it "should return an error object" do
        post :create, params: {reserve: {user_id: 1, biblio_id: 50, loan_type_id: 1}, token: @xallowed_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('UNPROCESSABLE_ENTITY')
        expect(json['errors']['errors'][0]['detail']).to eq('Required location_id is missing.')
      end
    end
    context "for a missing biblio_id" do
      it "should return an error object" do
        post :create, params: {reserve: {user_id: 1, location_id: 10, loan_type_id: 1}, token: @xallowed_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('UNPROCESSABLE_ENTITY')
        expect(json['errors']['errors'][0]['detail']).to eq('Required biblio_id is missing.')
      end
    end
    context "for a missing loan_type_id" do
      it "should return an error object" do
        post :create, params: {reserve: {user_id: 1, location_id: 10, biblio_id: 50}, token: @xallowed_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('UNPROCESSABLE_ENTITY')
        expect(json['errors']['errors'][0]['detail']).to eq('Required loan_type_id is missing.')
      end
    end

    context "for a valid reservation with a valid token" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/reserves/create?biblionumber=50&borrowernumber=1&branchcode=10&itemnumber=&password=password&reservenotes=L%C3%A5netyp:%20Heml%C3%A5n%20%0A&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 201, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-success.xml"), :headers => {})
      end
      it "should return a reserve object" do
        post :create, params: {reserve: {user_id: 1, location_id: 10, biblio_id: 50, loan_type_id: 1}, token: @xallowed_token.token}
        expect(json['reserve']).to_not be nil
      end
    end

    # context "when the CGI throws us a 403 error" do
    #   it "should return the error detail from the server" do
    #     "status"
    #   end
    # end

    # 403 - startswith "Reserve cannot be placed. Reason:"
    context "when the CGI throws us a 403 error" do
      it "should return the error detail from the server" do
        "Reserve cannot be placed. Reason: tooManyHoldsForThisRecord"
      end
    end

    # 400 - Item $itemnumber doesn't belong to biblio $biblionumber
    context "when the CGI throws us a 400 error" do
      it "should return the error detail from the server" do
        "Item $itemnumber doesn't belong to biblio $biblionumber"
      end
    end

    # 400 "Branchcode is required"
    context "when the CGI throws us a 400 error" do
      it "should return the error detail from the server" do
        "Branchcode is required"
      end
    end

    # 400 "At least one of biblionumber, itemnumber should be given"
    context "when the CGI throws us a 400 error" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/reserves/create?biblionumber=50&borrowernumber=1&branchcode=10&itemnumber=&password=password&reservenotes=L%C3%A5netyp:%20Heml%C3%A5n%20%0A&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 400, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-biblionumber-or-itemnumber.xml"), :headers => {})
      end
      it "should return the error detail from the server" do

        post :create, params: {reserve: {user_id: 1, location_id: 10, loan_type_id: 1}, token: @xallowed_token.token}
        pp json
        expect(json['errors']).to_not be nil
        expect(json['errors']['errors'][0]['detail']).to eq("At least one of biblionumber, itemnumber should be given")
      end
    end

    # 404 "Borrower not found"
    # view-source:http://koha-ref2-intra.ub.gu.se/cgi-bin/koha/svc/reserves/create?user=admin&password=KOHAadmin&borrowernumber=1
    context "when the borrower is not found in Koha" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/reserves/create?biblionumber=50&borrowernumber=1&branchcode=10&itemnumber=&password=password&reservenotes=L%C3%A5netyp:%20Heml%C3%A5n%20%0A&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-borrower-not-found.xml"), :headers => {})
      end
      it "should give us the error detail \"Borrower not found\"" do
        post :create, params: {reserve: {user_id: 1, location_id: 10, biblio_id: 50, loan_type_id: 1}, token: @xallowed_token.token}
        expect(json['errors']).to_not be nil
        expect(json['errors']['errors'][0]['detail']).to eq("Borrower not found")
      end
    end

    context "when the CGI throws us a 500 error" do
      it "should return the error detail from the server" do
        "Unknown error while placing reserve"
      end
    end








  end
end
