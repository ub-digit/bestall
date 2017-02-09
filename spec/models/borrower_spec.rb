require 'rails_helper'

RSpec.describe Borrower, :type => :model do
  describe "find_by_userid" do
    context "when borrower not exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xempty&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/borrower/borrower-empty.xml"), :headers => {})
      end
      it "should return nil" do
        borrower = Borrower.find_by_userid 'xempty'
        expect(borrower).to be_nil
      end
    end

    context "when borrower exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/borrower/borrower-1.xml"), :headers => {})
      end
      it "should return an object" do
        borrower = Borrower.find_by_userid 'xtest'
        expect(borrower).to_not be_nil
        expect(borrower).to be_kind_of(Borrower)
      end
      it "should return last name" do
        borrower = Borrower.find_by_userid 'xtest'
        expect(borrower).to_not be_nil
        expect(borrower.lastname).to eq("Person")
      end
      it "should return first name" do
        borrower = Borrower.find_by_userid 'xtest'
        expect(borrower).to_not be_nil
        expect(borrower.firstname).to eq("Test")
      end
      it "should return locked" do
        borrower = Borrower.find_by_userid 'xtest'
        expect(borrower).to_not be_nil
        expect(borrower.locked).to eq(true)
      end
    end
  end

  describe "as_json" do
    context "when borrower not exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xempty&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/borrower/borrower-empty.xml"), :headers => {})
      end
      it "should return nil" do
        borrower = Borrower.find_by_userid 'xempty'
        expect(borrower.as_json).to be_nil
      end
    end

    context "when borrower exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/borrower/borrower-1.xml"), :headers => {})
      end
      it "should return an object" do
        borrower = Borrower.find_by_userid 'xtest'
        expect(borrower.as_json).to_not be_nil
        expect(borrower).to be_kind_of(Borrower)
      end
      it "should return locked reasons object" do
        borrower = Borrower.find_by_userid 'xtest'
        expect(borrower).to_not be_nil
        expect(borrower.as_json[:locked_reasons]).to_not be_nil
      end
    end
  end

end
