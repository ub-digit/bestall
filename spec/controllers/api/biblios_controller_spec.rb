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

        expect(json['error']).to_not be nil
      end
    end

    context "when biblio exists but is denied for loans" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-denied.xml"), :headers => {})
      end
      it "should return an error object" do
        get :show, params: {id: 1}
        expect(json['error']).to_not be nil
      end
    end

    context "when biblio exists and is allowed for loans" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-allowed.xml"), :headers => {})
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
    end
  end
end
