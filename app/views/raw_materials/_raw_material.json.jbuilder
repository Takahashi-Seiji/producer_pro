json.extract! raw_material, :id, :name, :stock, :unit, :cost_per_unit, :created_at, :updated_at
json.url raw_material_url(raw_material, format: :json)
