require 'rails_helper'

RSpec.describe Sublocation, type: :model do
  describe "all" do
    before :each do
      WebMock.stub_request(:get, "http://koha.example.com/auth_values/list?category=LOC&password=password&userid=username").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/sublocation/sublocations.xml"), :headers => {})
    end
    it "should return a list of sublocations" do
      sublocations = Sublocation.all
      expect(sublocations).to be_truthy
    end
    it "should return a list of 3 sublocations" do
      sublocations = Sublocation.all
      expect(sublocations.length).to eq(3)
    end
    it "first sublocation should include id" do
      sublocation = Sublocation.all.first
      expect(sublocation.id).to be_truthy
    end
    it "first sublocation should include name_sv" do
      sublocation = Sublocation.all.first
      expect(sublocation.name_sv).to be_truthy
    end
    it "first sublocation should include name_en" do
      sublocation = Sublocation.all.first
      expect(sublocation.name_en).to be_truthy
    end
    it "first sublocation should include location_id" do
      sublocation = Sublocation.all.first
      expect(sublocation.location_id).to be_truthy
    end
    it "first sublocation should include is_open_loc" do
      sublocation = Sublocation.all.first
      expect(sublocation.is_open_loc).to be_truthy
    end
    it "first sublocation should include is_paging_loc" do
      sublocation = Sublocation.all.first
      expect(sublocation.is_open_loc).to be_truthy
    end
  end

  describe "find_all_by_location_id" do
    WebMock.stub_request(:get, "http://koha.example.com/auth_values/list?category=LOC&password=password&userid=username").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
      to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/sublocation/sublocations.xml"), :headers => {})
    it "should return all sublocations for a given location id" do
      sublocations = Sublocation.find_all_by_location_id(10)
      expect(sublocations).to_not be_nil
      expect(sublocations).to be_an(Array)
      expect(sublocations.size).to eq(3)
    end
  end

  describe "find_by_id" do
    WebMock.stub_request(:get, "http://koha.example.com/auth_values/list?category=LOC&password=password&userid=username").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
      to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/sublocation/sublocations.xml"), :headers => {})
    it "should return a sublocation" do
      sublocation = Sublocation.find_by_id(110005)
      expect(sublocation).to_not be_nil
    end
  end
end
