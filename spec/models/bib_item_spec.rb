require 'rails_helper'

RSpec.describe BibItem, :type => :model do
  describe "find_by_id" do
    context "when bib item not exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/999?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/bib_item/koha-empty.xml"), :headers => {})
      end
      it "should return nil" do
        bib_item = BibItem.find_by_id 999
        expect(bib_item).to be_nil
      end
    end

    context "when bib item exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/bib_item/koha-1.xml"), :headers => {})
      end
      it "should return an object" do
        bib_item = BibItem.find_by_id 1
        expect(bib_item).to_not be_nil
        expect(bib_item).to be_kind_of(BibItem)
      end
      it "should return title" do
        bib_item = BibItem.find_by_id 1
        expect(bib_item).to_not be_nil
        expect(bib_item.title).to eq("Test Title a Test Title b")
      end
      it "should return author" do
        bib_item = BibItem.find_by_id 1
        expect(bib_item).to_not be_nil
        expect(bib_item.author).to eq("Test, Author")
      end
      it "should return can_be_ordered" do
        bib_item = BibItem.find_by_id 1
        expect(bib_item).to_not be_nil
        expect(bib_item.can_be_ordered).to eq(false)
      end
    end
  end

end
