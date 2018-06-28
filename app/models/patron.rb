class Patron < ApplicationRecord
  # attributes:  name, email, login_id

  ## CONSTANTS

  ## VALIDATIONS
  validates_uniqueness_of :login_id
  validates_presence_of :login_id, :name, :email

  ## RELATIONS
  # has_many :search_tickets

  ## SCOPES

  ## METHODS


  def self.build_new_user(login_id, email, name)
    return Patron.new(name: name, login_id: login_id, email: email)
  end

end
