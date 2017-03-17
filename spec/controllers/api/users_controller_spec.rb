require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  describe "get current_user" do
    context "when token is empty" do
      it "should return an error object" do
        get :current_user, params: {id: 'xtest', token: ''}

        expect(json['errors']).to be_truthy
        expect(json['user']).to be_falsey
      end
    end

    context "user exists and is not denied" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xallowed&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-allowed.xml"), :headers => {})
        @xallowed_token = AccessToken.generate_token(User.find_by_username('xallowed'))
      end

      it "should return a user object" do
        get :current_user, params: {token: @xallowed_token.token}

        expect(json['user']).to_not be nil
      end
      it "should return last_name" do
        get :current_user, params: {token: @xallowed_token.token}

        expect(json['user']['last_name']).to_not be nil
      end
      it "should return first_name" do
        get :current_user, params: {token: @xallowed_token.token}

        expect(json['user']['first_name']).to_not be nil
      end
      it "should return denied" do
        get :current_user, params: {token: @xallowed_token.token}

        expect(json['user']['denied']).to_not be nil
      end
      it "should return no denied_reasons" do
        get :current_user, params: {token: @xallowed_token.token}

        expect(json['user']['denied_reasons']).to be nil
      end

    end

    context "user exists but is denied" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xdenied&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-denied.xml"), :headers => {})
        @xdenied_token = AccessToken.generate_token(User.find_by_username('xdenied'))
      end
      it "should return an error object" do
        get :current_user, params: {token: @xdenied_token.token}

        expect(json['errors']).to_not be nil
      end
    end

    context "user has borrowed an item of this biblio" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-has-issues.xml"), :headers => {})
        @xtest_token = AccessToken.generate_token(User.find_by_username('xtest'))
        WebMock.stub_request(:get, "http://koha.example.com/bib/1385442?items=1&password=password&userid=username").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
         to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-monograph.xml"), :headers => {})
        WebMock.stub_request(:get, "http://koha.example.com/reserves/list?biblionumber=1385442&password=password&userid=username").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
         to_return(:status => 200, :body => "", :headers => {})
      end
      it "should return an error object" do
        get :current_user, params: {token: @xtest_token.token, biblio: 1385442}
        expect(json['errors']).to_not be nil
      end
    end

    context "user has reserved an item of this biblio" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/members/get?borrower=xtest&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/patron/patron-has-reserves.xml"), :headers => {})
        @xtest_token = AccessToken.generate_token(User.find_by_username('xtest'))
        WebMock.stub_request(:get, "http://koha.example.com/bib/191130?items=1&password=password&userid=username").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
         to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/biblio/biblio-monograph.xml"), :headers => {})
        WebMock.stub_request(:get, "http://koha.example.com/reserves/list?biblionumber=191130&password=password&userid=username").
         with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
         to_return(:status => 200, :body => "", :headers => {})
      end
      it "should return an error object" do
        get :current_user, params: {token: @xtest_token.token, biblio: 191130}
        expect(json['errors']).to_not be nil
      end
    end
  end
end
