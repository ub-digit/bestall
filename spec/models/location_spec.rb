require 'rails_helper'

RSpec.describe Location, type: :model do
  describe "all" do
    before :each do
      WebMock.stub_request(:get, "http://koha.example.com/branches/list?password=password&userid=username").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/location/branches.xml"), :headers => {})
    end
    it "should return a list of locations" do
      locations = Location.all
      expect(locations).to be_truthy
    end
    it "should return a list of 3 locations" do
      locations = Location.all
      expect(locations.length).to eq(3)
    end
    it "first location should include id" do
      location = Location.all.first
      expect(location.id).to be_truthy
    end
    it "first location should include name_sv" do
      location = Location.all.first
      expect(location.name_sv).to be_truthy
    end
    it "first location should include name_en" do
      location = Location.all.first
      expect(location.name_en).to be_truthy
    end
    it "first location should categories" do
      location = Location.all.first
      expect(location.categories).to be_truthy
    end
  end
end
