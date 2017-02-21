require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do

  describe "get current_user" do
    context "user exists but is denied" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-1.xml"), :headers => {})
      end
      it "should return an error object" do
        get :current_user, params: {username: 'xtest'}

        expect(json['error']).to_not be nil
      end
    end

    context "user does not exist" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xempty&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/patron/patron-empty.xml"), :headers => {})
      end
      it "should return an error object" do
        get :current_user, params: {username: 'xempty'}

        expect(json['error']).to_not be nil
      end
    end

    context "user does exist and is allowed to borrow" do
      it "should return an error object" do
        skip "test for user exists and is allowed to borrow"
      end
    end

  end

end
