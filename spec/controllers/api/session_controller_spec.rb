require 'rails_helper'

RSpec.describe Api::SessionController, :type => :controller do
  describe "create" do
    context "when patron not exists in Koha" do
      before :each do
        WebMock.stub_request(:get, "https://caslogin.example.com/serviceValidate?service=myapp.example.com&ticket=VALID-NO-KOHA-USER").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/cas/cas-success-user-not-in-koha.xml"), :headers => {})

        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xempty&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/patron/patron-empty.xml"), :headers => {})
      end

      it "should return error on invalid credentials" do
        post :create, params: {cas_ticket: "VALID-NO-KOHA-USER", cas_service: "myapp.example.com"}

        expect(json['error']).to be_truthy

        expect(json['user']).to be_falsey
        expect(json['access_token']).to be_falsey
        expect(json['token_type']).to be_falsey
      end
    end

    context "when patron exists in Koha" do
      before :each do
        WebMock.stub_request(:get, "https://caslogin.example.com/serviceValidate?service=myapp.example.com&ticket=VALID-KOHA-USER").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/cas/cas-success-user-in-koha.xml"), :headers => {})

        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-1.xml"), :headers => {})
      end

      it "should return username on valid credentials" do
        post :create, params: {cas_ticket: "VALID-KOHA-USER", cas_service: "myapp.example.com"}

        expect(json['access_token']).to be_truthy
        expect(json['token_type']).to eq("bearer")
        expect(json['access_token']).to eq(AccessToken.find_by_username('xtest').token)
      end

      it "should return a user object" do
        get :create, params: {cas_ticket: "VALID-KOHA-USER", cas_service: "myapp.example.com"}

        expect(json['user']).to_not be nil
      end
      it "should return last_name" do
        get :create, params: {cas_ticket: "VALID-KOHA-USER", cas_service: "myapp.example.com"}

        expect(json['user']['last_name']).to_not be nil
      end
      it "should return first_name" do
        get :create, params: {cas_ticket: "VALID-KOHA-USER", cas_service: "myapp.example.com"}

        expect(json['user']['first_name']).to_not be nil
      end
      it "should return denied" do
        get :create, params: {cas_ticket: "VALID-KOHA-USER", cas_service: "myapp.example.com"}

        expect(json['user']['denied']).to_not be nil
      end
      it "should return locked_reasons" do
        get :create, params: {cas_ticket: "VALID-KOHA-USER", cas_service: "myapp.example.com"}

        expect(json['user']['denied_reasons']).to_not be nil
        expect(json['user']['denied_reasons']).to be_kind_of(Hash)
      end
    end
  end
end
