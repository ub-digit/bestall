require 'rails_helper'

RSpec.describe User, :type => :model do
  describe "find_by_username" do
    context "when patron not exists in Koha" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xempty&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/patron/patron-empty.xml"), :headers => {})
      end
      it "should return nil" do
        user = User.find_by_username 'xempty'
        expect(user).to be_nil
      end
    end

    context "when user exists in Koha" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-1.xml"), :headers => {})
      end
      it "should return an object" do
        user = User.find_by_username 'xtest'
        expect(user).to_not be_nil
        expect(user).to be_kind_of(User)
      end
      it "should return id" do
        user = User.find_by_username 'xtest'
        expect(user).to_not be_nil
        expect(user.id).to eq(2)
      end
      it "should return last name" do
        user = User.find_by_username 'xtest'
        expect(user).to_not be_nil
        expect(user.last_name).to eq("Person")
      end
      it "should return first name" do
        user = User.find_by_username 'xtest'
        expect(user).to_not be_nil
        expect(user.first_name).to eq("Test")
      end
    end
  end

  describe "as_json" do
    context "when patron not exists  in Koha" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xempty&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/patron/patron-empty.xml"), :headers => {})
      end
      it "should return nil" do
        user = User.find_by_username 'xempty'
        expect(user.as_json).to be_nil
      end
    end

    context "when patron exists in Koha" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-1.xml"), :headers => {})
      end
      it "should return a user object" do
        user = User.find_by_username 'xtest'
        expect(user.as_json).to_not be_nil
        expect(user).to be_kind_of(User)
      end
    end
  end

  describe "has_borrowed_item?" do
    before :each do
      WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-has-issues.xml"), :headers => {})
    end
    it "should return true when patron has borrowed the item" do
        user = User.find_by_username 'xtest'
        expect(user).to_not be_nil
        expect(user.has_borrowed_item?("1385442")).to eq true
    end
    it "should return false when patron has not borrowed the item" do
        user = User.find_by_username 'xtest'
        expect(user).to_not be_nil
        expect(user.has_borrowed_item?("1032561")).to eq false
    end
  end


  describe "has_reserved_item?" do
    before :each do
      WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
        to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-has-reserves.xml"), :headers => {})
    end
    it "should return true when patron has reserved the item" do
        user = User.find_by_username 'xtest'
        expect(user).to_not be_nil
        expect(user.has_reserved_item?("191130")).to eq true
    end
    it "should return false when patron has not reserved the item" do
        user = User.find_by_username 'xtest'
        expect(user).to_not be_nil
        expect(user.has_reserved_item?("1032561")).to eq false
    end
  end
end
