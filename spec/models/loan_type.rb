require 'rails_helper'

RSpec.describe LoanType, type: :model do
  describe "all" do
    it "should return a list of loan types" do
      loan_types = LoanType.all
      expect(locations).to be_truthy
    end
    it "first loan_types should include id" do
      loan_types = LoanType.all.first
      expect(loan_types.id).to be_truthy
    end
    it "first loan_types should include name_sv" do
      loan_types = LoanType.all.first
      expect(loan_types.name_sv).to be_truthy
    end
    it "first loan_types should include name_en" do
      loan_types = LoanType.all.first
      expect(loan_types.name_en).to be_truthy
    end
  end
end
