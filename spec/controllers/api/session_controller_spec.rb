require 'rails_helper'

RSpec.describe Api::SessionController, :type => :controller do
  before :each do
    #WebMock.disable_net_connect!
    WebMock.allow_net_connect!
  end
  after :each do
    WebMock.allow_net_connect!
  end

######
#
#
# 1 Verifiera mot CAS-servern.
# 2 Generera token för lyckad inloggning.
# 3 Returnera användarnamnet till FE.
# 4 Se dFlow
#
#

  describe "create" do
=begin
    it "should return username on valid credentials" do
      post :create, cas_ticket: "asdf", cas_service: "localhost:3000"
      #user = User.find_by_username("admin")
      pp ["json", json]
      expect(json['access_token']).to be_truthy
      expect(json['token_type']).to eq("bearer")
      expect(json['access_token']).to eq(user.access_tokens.first.token)
    end

    context "when patron not exists in Koha" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xempty&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/patron/patron-empty.xml"), :headers => {})
      end
      it "should return an error object" do
        get :create, params: {id: 'xempty'}
        expect(json['error']).to_not be nil
      end
    end

    context "when patron exists in Koha" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-1.xml"), :headers => {})
      end
      it "should return an borrower object" do
        get :show, params: {id: 'xtest'}

        expect(json['user']).to_not be nil
      end
      it "should return lastname" do
        get :show, params: {id: 'xtest'}

        expect(json['user']['last_name']).to_not be nil
      end
      it "should return firstname" do
        get :show, params: {id: 'xtest'}

        expect(json['user']['first_name']).to_not be nil
      end
      it "should return locked" do
        get :show, params: {id: 'xtest'}

        expect(json['user']['denied']).to_not be nil
      end
      it "should return locked_reasons" do
        get :show, params: {id: 'xtest'}

        expect(json['user']['denied_reasons']).to_not be nil
        expect(json['user']['denied_reasons']).to be_kind_of(Hash)
      end
    end
=end
  end
end