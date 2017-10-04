require 'rails_helper'

RSpec.describe Api::PrintController, type: :controller do

  describe "create" do
    context "with no api key" do
      it "should return an authentication error" do
        post :create, params: {}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('UNAUTHORIZED')
      end
    end
    context "with a non valid api key" do
      it "should return an authentication error" do
        post :create, params: {api_key: 'non_valid_api_key'}
        expect(json['errors']).to_not be nil
        expect(json['errors']['code']).to eq('UNAUTHORIZED')
      end
    end
    context "with a valid api key" do
      it "should return success" do
        post :create, params: {api_key: 'valid_api_key'}
        expect(json['errors']).to be nil
      end
    end
  end
end
