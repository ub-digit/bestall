class LoanType
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attr_accessor :id, :name_sv, :name_en, :show_pickup_location, :is_disabled

  LOAN_TYPE_HOME_LOAN = 1
  LOAN_TYPE_READING_ROOM_LOAN = 2
  LOAN_TYPE_RESEARCHER_LOCKER = 3
  LOAN_TYPE_DEPARTMENT = 4
  LOAN_TYPE_SEND_MATERIAL = 5

  LOAN_TYPES =
    [
      {id: LOAN_TYPE_HOME_LOAN, position: 2, show_pickup_location: true, name_sv: 'Hämta materialet i biblioteket (hemlån)', name_en: 'Pick up the material at the library (home loan)', is_disabled: false},
      {id: LOAN_TYPE_READING_ROOM_LOAN, position: 3, show_pickup_location: true, name_sv: 'Läs materialet i biblioteket (läsesalslån)', name_en: 'Read the material in the library (reading room loan)', is_disabled: false},
      {id: LOAN_TYPE_RESEARCHER_LOCKER, position: 4, show_pickup_location: true, name_sv: 'Forskarskåp (tillstånd krävs)', name_en: 'Loan to researcher’s locker (permit required)', is_disabled: false},
      {id: LOAN_TYPE_DEPARTMENT, position: 5, show_pickup_location: true, name_sv: 'Institutionslån (tillstånd krävs)', name_en: 'Loan to department (permit required)', is_disabled: false},
      {id: LOAN_TYPE_SEND_MATERIAL, position: 1, show_pickup_location: false, name_sv: 'Skicka materialet till mig', name_en: 'Send the material to me', is_disabled: false}
    ]

  def initialize id:, name_sv:, name_en:, show_pickup_location:, is_disabled:
    @id = id
    @show_pickup_location = show_pickup_location
    @name_sv = name_sv
    @name_en = name_en
    @is_disabled = is_disabled
  end

  def self.where(category_code:, item_type:, status_limitation:)
    loan_types = []
    LOAN_TYPES.sort_by {|lt|lt[:position]}.each do |lt|

      is_disable = lt[:is_disabled]
      if [LOAN_TYPE_HOME_LOAN, LOAN_TYPE_SEND_MATERIAL].include?(lt[:id])
        if ['8', '17'].include?(item_type) || ['READING_ROOM_ONLY', 'NOT_FOR_HOME_LOAN'].include?(status_limitation)
          is_disable = true
        end
      end

      if lt[:id] == LOAN_TYPE_SEND_MATERIAL && !['SD', 'FT'].include?(category_code)
        next
      end

      loan_types << self.new(id: lt[:id], show_pickup_location: lt[:show_pickup_location], name_sv: lt[:name_sv], name_en: lt[:name_en], is_disabled: is_disable)
    end
    loan_types
  end

  def self.find_by_id(id)
    loan_type_hash = LOAN_TYPES.select {|lt| lt[:id] == id}.first
    if loan_type_hash
      self.new(id: loan_type_hash[:id], show_pickup_location: loan_type_hash[:show_pickup_location], name_sv: loan_type_hash[:name_sv], name_en: loan_type_hash[:name_en], is_disabled: loan_type_hash[:is_disabled])
    else
      nil
    end
  end

  def send_material?
    @id == LOAN_TYPE_SEND_MATERIAL
  end
end
