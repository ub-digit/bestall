require 'rails_helper'

RSpec.describe Api::SessionController, :type => :controller do
  before :each do
    WebMock.disable_net_connect!
  end
  after :each do
    WebMock.allow_net_connect!
  end
end
