class LoanType
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :name_sv, :name_en, :show_pickup_location

  LOAN_TYPES = [{id: 1, position: 2, show_pickup_location: true, name_sv: 'Hämta materialet i biblioteket (hemlån)', name_en: 'Pick up the material at the library (home loan)'},
                {id: 2, position: 3, show_pickup_location: true, name_sv: 'Läs materialet i biblioteket (läsesalslån)', name_en: 'Read the material in the library (reading room loan)'},
                {id: 3, position: 4, show_pickup_location: true, name_sv: 'Forskarskåp (tillstånd krävs)', name_en: 'Loan to researcher’s locker (permit required)'},
                {id: 4, position: 5, show_pickup_location: true, name_sv: 'Institutionslån (tillstånd krävs)', name_en: 'Loan to department (permit required)'},
                {id: 5, position: 1, show_pickup_location: false, name_sv: 'Skicka hem materialet till mig (tillstånd krävs)', name_en: 'Send the material to my home (permit required)'}]

  def initialize id:, name_sv:, name_en:, show_pickup_location:
    @id = id
    @show_pickup_location = show_pickup_location
    @name_sv = name_sv
    @name_en = name_en
  end

  def self.all
    loan_types = []
    LOAN_TYPES.sort_by {|lt|lt[:position]}.each do |lt|
      loan_types << self.new(id: lt[:id], show_pickup_location: lt[:show_pickup_location], name_sv: lt[:name_sv], name_en: lt[:name_en])
    end
    loan_types
  end

  def self.find_by_id(id)
    loan_type_hash = LOAN_TYPES.select {|lt| lt[:id] == id}.first
    if loan_type_hash
      self.new(id: loan_type_hash[:id], show_pickup_location: loan_type_hash[:show_pickup_location], name_sv: loan_type_hash[:name_sv], name_en: loan_type_hash[:name_en])
    else
      nil
    end
  end

end
