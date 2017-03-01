require 'rails_helper'

RSpec.describe Biblio, :type => :model do
  describe "find_by_id" do
    context "when bib item not exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/999?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-empty.xml"), :headers => {})
        WebMock.stub_request(:get, "http://koha.example.com/reserves/list?biblionumber=999&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => "", :headers => {})
      end
      it "should return nil" do
        biblio = Biblio.find_by_id 999
        expect(biblio).to be_nil
      end
    end

    context "when bib item exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-1.xml"), :headers => {})
        WebMock.stub_request(:get, "http://koha.example.com/reserves/list?biblionumber=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => "", :headers => {})
      end
      it "should return an object" do
        biblio = Biblio.find_by_id 1
        expect(biblio).to_not be_nil
        expect(biblio).to be_kind_of(Biblio)
      end
      it "should return title" do
        biblio = Biblio.find_by_id 1
        expect(biblio).to_not be_nil
        expect(biblio.title).to eq("Test Title a Test Title b")
      end
      it "should return author" do
        biblio = Biblio.find_by_id 1
        expect(biblio).to_not be_nil
        expect(biblio.author).to eq("Test, Author")
      end
      it "should return can_be_borrowed" do
        biblio = Biblio.find_by_id 1
        expect(biblio).to_not be_nil
        expect(biblio.can_be_borrowed).to eq(false)
      end
      it "should return record_type" do
        biblio = Biblio.find_by_id 1
        expect(biblio).to_not be_nil
        expect(biblio.record_type).to eq("monograph")
      end
      it "should return can_be_queued" do
        biblio = Biblio.find_by_id 1
        expect(biblio.can_be_queued).to_not be_nil
      end
    end
  end

  describe "can_be_queued" do
    context "item can be queued" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/item/item-can-queue.xml"), :headers => {})
      end
      it "should return can_be_queued true" do
        biblio = Biblio.find_by_id 1
        expect(biblio.can_be_queued).to be_truthy
      end
    end

    context "item can not be queued" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/item/item-cannot-queue.xml"), :headers => {})
      end
      it "should return can_be_queued false" do
        biblio = Biblio.find_by_id 1
        expect(biblio.can_be_queued).to be_falsey
      end
    end
  end

  describe "can_be_queued_on_item" do
    context "biblio is a monograph" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-monograph.xml"), :headers => {})
      end
      it "should return can_be_queued_on_item false" do
        biblio = Biblio.find_by_id 1
        expect(biblio.can_be_queued_on_item).to be_falsey
      end
    end
    context "biblio is a serial" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-serial.xml"), :headers => {})
      end
      it "should return can_be_queued_on_item true" do
        biblio = Biblio.find_by_id 1
        expect(biblio.can_be_queued_on_item).to be_truthy
      end
    end
  end

  describe "methods" do
    context "parse_record_type" do
      it "should return monographic_component for a" do
        record_type = Biblio.parse_record_type("     caa a22 ar4500")
        expect(record_type).to eq("monographic_component")
      end
      it "should return serial_component for b" do
        record_type = Biblio.parse_record_type("     cab a22 ar4500")
        expect(record_type).to eq("serial_component")
      end
      it "should return collection for c" do
        record_type = Biblio.parse_record_type("     cac a22 ar4500")
        expect(record_type).to eq("collection")
      end
      it "should return subunit for d" do
        record_type = Biblio.parse_record_type("     cad a22 ar4500")
        expect(record_type).to eq("subunit")
      end
      it "should return integrating_resource for i" do
        record_type = Biblio.parse_record_type("     cai a22 ar4500")
        expect(record_type).to eq("integrating_resource")
      end
      it "should return monograph for m" do
        record_type = Biblio.parse_record_type("     cam a22 ar4500")
        expect(record_type).to eq("monograph")
      end
      it "should return serial for s" do
        record_type = Biblio.parse_record_type("     cas a22 ar4500")
        expect(record_type).to eq("serial")
      end
      it "should return other for q" do
        record_type = Biblio.parse_record_type("     caq a22 ar4500")
        expect(record_type).to eq("other")
      end
    end
  end
end
