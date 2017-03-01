require 'rails_helper'

RSpec.describe Api::LocationsController, type: :controller do

  describe "get index" do
    before :each do
      WebMock.stub_request(:get, "http://koha.example.com/branches/list?password=password&userid=username").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/location/branches.xml"), :headers => {})
      WebMock.stub_request(:get, "http://koha.example.com/auth_values/list?category=LOC&password=password&userid=username").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/sublocation/sublocations.xml"), :headers => {})
    end
    it "should return an ordered list of location objects" do
      get :index

      expect(json['locations']).to be_truthy
      expect(json['locations']).to be_kind_of(Array)
      expect(json['locations'].length).to eq(3)

      location_ids = json['locations'].map do |location|
        location['id']
      end
      expect(location_ids).to eq(['10', '11', '12'])

      expect(json['locations'][0]['name_sv']).to eq('Bibl för musik och dramatik (MoD)')
      expect(json['locations'][0]['categories']).to be_kind_of(Array)
      expect(json['locations'][0]['categories'].length).to eq(1)

      expect(json['locations'][0]['sublocations']).to be_kind_of(Array)
      expect(json['locations'][0]['sublocations'].length).to eq(2)

    end
  end
end
