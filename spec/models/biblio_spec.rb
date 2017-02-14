require 'rails_helper'

RSpec.describe Biblio, :type => :model do
  describe "find_by_id" do
    context "when bib item not exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/999?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-empty.xml"), :headers => {})
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
      it "should return can_be_ordered" do
        biblio = Biblio.find_by_id 1
        expect(biblio).to_not be_nil
        expect(biblio.can_be_ordered).to eq(false)
      end
    end
  end

end
