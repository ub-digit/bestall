require 'rails_helper'

RSpec.describe Api::LocationsController, type: :controller do

  describe "get index" do
    before :each do
      WebMock.stub_request(:get, "http://koha.example.com/branches/list?password=password&userid=username").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/location/branches.xml"), :headers => {})
    end
    it "should return a list of location objects" do
      get :index

      expect(json['locations']).to be_truthy
      expect(json['locations']).to be_kind_of(Array)
      expect(json['locations'].length).to eq(3)
    end
  end
end