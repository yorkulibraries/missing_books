json.extract! search_area, :id, :name, :location_id, :primary, :created_at, :updated_at
json.url admin_search_area_url(search_area, format: :json)
