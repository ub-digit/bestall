require 'rails_helper'

RSpec.describe Api::SessionController, :type => :controller do
  before :each do
    #WebMock.disable_net_connect!
    WebMock.allow_net_connect!
  end
  after :each do
    WebMock.allow_net_connect!
  end

  describe "create" do
    it "should return username on valid credentials" do
      post :create, cas_ticket: "asdf", cas_service: "localhost:3000"
      #user = User.find_by_username("admin")
      pp ["json", json]
      expect(json['access_token']).to be_truthy
      expect(json['token_type']).to eq("bearer")
      expect(json['access_token']).to eq(user.access_tokens.first.token)



      # stub_request(:get, "https://caslogin.example.com/serviceValidate?service=localhost:3000&ticket=asdf").
      #    with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      #    to_return(:status => 200, :body => "", :headers => {})
    end
  end
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
