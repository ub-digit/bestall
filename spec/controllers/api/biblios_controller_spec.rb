require 'rails_helper'

RSpec.describe Api::BibliosController, type: :controller do

  describe "get show" do
    context "when biblio not exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/999?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-empty.xml"), :headers => {})
      end
      it "should return an error object" do
        get :show, params: {id: 999}

        expect(json['error']).to_not be nil
      end
    end

    context "when biblio exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/bib/1?items=1&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-1.xml"), :headers => {})
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
      it "should return can_be_ordered" do
        get :show, params: {id: 1}

        expect(json['biblio']['can_be_ordered']).to_not be nil
      end
    end
  end
end
