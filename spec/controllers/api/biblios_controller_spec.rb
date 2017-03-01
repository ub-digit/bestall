require 'rails_helper'

RSpec.describe Api::BibliosController, type: :controller do

  describe "get show" do
    context "when biblio not exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/999?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-empty.xml"), :headers => {})
      end
      it "should return an error object" do
        get :show, params: {id: 999}

        expect(json['errors']).to_not be nil
      end
    end

    context "when biblio exists but is denied for loans" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-cannot-borrow.xml"), :headers => {})
        WebMock.stub_request(:get, "http://koha.example.com/reserves/list?biblionumber=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-empty.xml"), :headers => {})
      end
      it "should return an error object" do
        get :show, params: {id: 1}
        expect(json['errors']).to_not be nil
      end
    end

    context "when biblio exists and is allowed for loans" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-can-borrow.xml"), :headers => {})
        WebMock.stub_request(:get, "http://koha.example.com/reserves/list?biblionumber=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-empty.xml"), :headers => {})
      end
      it "should return an biblio object" do
        get :show, params: {id: 1}
        expect(json['biblio']).to_not be nil
      end
      it "should return author" do
        get :show, params: {id: 1}
        expect(json['biblio']['author']).to_not be nil
      end
      it "should return title" do
        get :show, params: {id: 1}
        expect(json['biblio']['title']).to_not be nil
      end
      it "should return an array of items" do
        get :show, params: {id: 1}
        expect(json['biblio']['items']).to be_kind_of(Array)
        expect(json['biblio']['items'].length).to eq(1)
      end
      it "should return a record type" do
        get :show, params: {id: 1}
        expect(json['biblio']['record_type']).to_not be nil
      end
      it "should return a flag for can_be_queued" do
        get :show, params: {id: 1}
        expect(json['biblio']['can_be_queued']).to_not be nil
      end
      it "should return a flag for can_be_queued_on_item" do
        get :show, params: {id: 1}
        expect(json['biblio']['can_be_queued_on_item']).to_not be nil
      end
    end
    context "item contains only id" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-sparse-item.xml"), :headers => {})
        WebMock.stub_request(:get, "http://koha.example.com/reserves/list?biblionumber=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-empty.xml"), :headers => {})
      end
      it "should return an item with the correct attributes" do
        get :show, params: {id: 1}
        item = json['biblio']['items'][0]
        expect(item).to have_key('id')
        expect(item).to have_key('biblio_id')
        expect(item).to have_key('can_be_ordered')
      end
    end
  end
end
