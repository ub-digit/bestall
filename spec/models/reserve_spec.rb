require 'rails_helper'

RSpec.describe Reserve, type: :model do
  describe "add" do
    context "for an invalid reservation" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/reserves/create?biblionumber=50&borrowernumber=999&branchcode=10&itemnumber=&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 403, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-cannot-be-placed.xml"), :headers => {})
      end
      it "should not return a Reserve object" do
        reserve = Reserve.add(borrowernumber: 999, branchcode: 10, biblionumber: 50)
        expect(reserve).to be_falsey
      end
    end

    context "for a valid reservation" do
      before :each do
        WebMock.stub_request(:get, "http://koha.example.com/reserves/create?biblionumber=50&borrowernumber=1&branchcode=10&itemnumber=&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 201, :body => File.new("#{Rails.root}/spec/support/reserve/reserve-success.xml"), :headers => {})
      end
      it "should return a Reserve object" do
        reserve = Reserve.add(borrowernumber: 1, branchcode: 10, biblionumber: 50)
        expect(reserve).to be_truthy
      end
      it "should return id" do
        reserve = Reserve.add(borrowernumber: 1, branchcode: 10, biblionumber: 50)
        expect(reserve.id).to be_truthy
        expect(reserve.id).to eq 100

      end
      it "should return borrowernumber" do
        reserve = Reserve.add(borrowernumber: 1, branchcode: 10, biblionumber: 50)
        expect(reserve.borrowernumber).to be_truthy
      end
      it "should return branchcode" do
        reserve = Reserve.add(borrowernumber: 1, branchcode: 10, biblionumber: 50)
        expect(reserve.branchcode).to be_truthy
      end
      it "should return biblionumber" do
        reserve = Reserve.add(borrowernumber: 1, branchcode: 10, biblionumber: 50)
        expect(reserve.biblionumber).to be_truthy
      end
      it "should return reservedate" do
        reserve = Reserve.add(borrowernumber: 1, branchcode: 10, biblionumber: 50)
        expect(reserve.reservedate).to be_truthy
      end
      it "should return timestamp" do
        reserve = Reserve.add(borrowernumber: 1, branchcode: 10, biblionumber: 50)
        expect(reserve.timestamp).to be_truthy
      end
    end
  end
end


