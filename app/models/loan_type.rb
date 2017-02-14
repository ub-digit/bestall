class LoanType
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :name_sv, :name_en

  LOAN_TYPES = [{id: 1, name_sv: 'Hemlån', name_en: 'Hemlån'},
                {id: 2, name_sv: 'Läsesal', name_en: 'Läsesal'},
                {id: 3, name_sv: 'Forskarskåp', name_en: 'Forskarskåp'},
                {id: 4, name_sv: 'Institutionslån', name_en: 'Institutionslån'}]

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

end
