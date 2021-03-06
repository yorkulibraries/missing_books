class Employee < ApplicationRecord
  # attributes:  name, email, location_id, role, login_id, active

  ## CONSTANTS
  ROLE_MANAGER="manager"
  ROLE_COORDINATOR="coordinator"
  ROLE_LEVEL_ONE ="service_level_one"
  ROLE_LEVEL_TWO ="service_level_two"
  ROLES = [ ROLE_MANAGER, ROLE_COORDINATOR, ROLE_LEVEL_ONE, ROLE_LEVEL_TWO ]

  ## RELATIONS
  belongs_to :location, optional: false

  has_many :tickets_in_location, -> (e) { where(location_id: e.location_id) }, foreign_key: "assigned_to_id", class_name: "SearchTicket"
  has_many :assigned_tickets, foreign_key: "assigned_to_id", class_name: "SearchTicket"
  has_many :work_logs, class_name: "SearchTicket::WorkLog"

  ## VALIDATIONS
  validates_uniqueness_of :login_id
  validates_presence_of :login_id, :name, :email, :role, :location_id

  ## SCOPES
  scope :by_role, -> { order(:role) }

  #callbacks
  after_create :create_patron_account


  ## METHODS
  def initials
    if name != nil
      return name.split(" ").map {|i|  i[0,1].capitalize }.join.ljust(2, "_")
    else
      return "##"
    end
  end

  def create_patron_account
    patron = Patron.build_new_user(login_id, email, name)
    patron.save(validate: false)
  end


  def patron
    Patron.find_by_login_id(login_id)
  end
end
