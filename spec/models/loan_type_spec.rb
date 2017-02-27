require 'rails_helper'

RSpec.describe LoanType, type: :model do
  describe "all" do
    it "should return a list of loan types" do
      loan_types = LoanType.all
      expect(loan_types).to be_truthy
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
  describe "find_by_id" do
    it "should return nil when loan type not exists" do
      loan_type = LoanType.find_by_id 99
      expect(loan_type).to be_falsey
    end
    it "should return a loan type object when loan type exists" do
      loan_type = LoanType.find_by_id 1
      expect(loan_type).to be_truthy
    end
  end
end
