json.extract! employee, :id, :name, :role, :login_id, :email, :location_id, :active, :created_at, :updated_at
json.url employee_url(employee, format: :json)
