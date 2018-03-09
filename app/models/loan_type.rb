class LoanType
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :name_sv, :name_en

  LOAN_TYPES = [{id: 1, name_sv: 'Hemlån', name_en: 'Home loan'},
                {id: 2, name_sv: 'Läsesal', name_en: 'Reading room loan'},
                {id: 3, name_sv: 'Forskarskåp', name_en: 'Loan to researcher’s locker'},
                {id: 4, name_sv: 'Institutionslån', name_en: 'Loan to department (permit required)'}]

  def initialize id:, name_sv:, name_en:
    @id = id
    @name_sv = name_sv
    @name_en = name_en
  end

  def self.all
    loan_types = []
    LOAN_TYPES.each do |lt|
      loan_types << self.new(id: lt[:id], name_sv: lt[:name_sv], name_en: lt[:name_en])
    end
    loan_types
  end

  def self.find_by_id(id)
    loan_type_hash = LOAN_TYPES.select {|lt| lt[:id] == id}.first
    if loan_type_hash
      self.new(id: loan_type_hash[:id], name_sv: loan_type_hash[:name_sv], name_en: loan_type_hash[:name_en])
    else
      nil
    end
  end

end
