require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do

  describe "show" do
    before :each do
      @xtest_token = AccessToken.generate_token(User.find_by_username('xtest'))
    end
    context "when requesting user is not same as current_user" do
      it "should return an error object" do

        get :show, params: {id: 'xother', token: @xtest_token.token}

        expect(json['error']).to be_truthy
        expect(json['user']).to be_falsey
      end
    end

    context "when token is empty" do
      it "should return an error object" do

        get :show, params: {id: 'xtest', token: ''}

        expect(json['error']).to be_truthy
        expect(json['user']).to be_falsey
      end
    end

    context "when patron not exists in Koha" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xempty&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 404, :body => File.new("#{Rails.root}/spec/support/patron/patron-empty.xml"), :headers => {})
      end

      it "should return error" do
        get :show, params: {id: 'xempty'}

        expect(json['error']).to be_truthy
        expect(json['user']).to be_falsey
      end
    end

    context "when patron exists in Koha" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-1.xml"), :headers => {})
      end

      it "should return a user object" do
        get :show, params: {id: @xtest_token.username, token: @xtest_token.token}

        expect(json['user']).to_not be nil
      end
      it "should return last_name" do
        get :show, params: {id: @xtest_token.username, token: @xtest_token.token}

        expect(json['user']['last_name']).to_not be nil
      end
      it "should return first_name" do
        get :show, params: {id: @xtest_token.username, token: @xtest_token.token}

        expect(json['user']['first_name']).to_not be nil
      end
      it "should return denied" do
        get :show, params: {id: @xtest_token.username, token: @xtest_token.token}

        expect(json['user']['denied']).to_not be nil
      end
      it "should return denied_reasons" do
        get :show, params: {id: @xtest_token.username, token: @xtest_token.token}

        expect(json['user']['denied_reasons']).to_not be nil
        expect(json['user']['denied_reasons']).to be_kind_of(Hash)
      end
    end
  end

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
