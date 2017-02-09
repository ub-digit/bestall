require 'rails_helper'

RSpec.describe Api::BorrowersController, type: :controller do

  describe "get show" do
    context "when borrower not exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xempty&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/borrower/borrower-empty.xml"), :headers => {})
      end
      it "should return an error object" do
        get :show, params: {id: 'xempty'}
        expect(json['error']).to_not be nil
      end
    end

    context "when borrower exists" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com', 'User-Agent'=>'rest-client/2.0.0 (linux-gnu x86_64) ruby/2.3.1p112'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/borrower/borrower-1.xml"), :headers => {})
      end
      it "should return an borrower object" do
        get :show, params: {id: 'xtest'}

        expect(json['borrower']).to_not be nil
      end
      it "should return lastname" do
        get :show, params: {id: 'xtest'}

        expect(json['borrower']['lastname']).to_not be nil
      end
      it "should return firstname" do
        get :show, params: {id: 'xtest'}

        expect(json['borrower']['firstname']).to_not be nil
      end
      it "should return locked" do
        get :show, params: {id: 'xtest'}

        expect(json['borrower']['locked']).to_not be nil
      end
      it "should return locked_reasons" do
        get :show, params: {id: 'xtest'}

        expect(json['borrower']['locked_reasons']).to_not be nil
        expect(json['borrower']['locked_reasons']).to be_kind_of(Hash)
      end
    end
  end
end
