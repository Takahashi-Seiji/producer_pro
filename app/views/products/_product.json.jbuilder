json.extract! product, :id, :name, :stock, :unit, :price_per_unit, :description, :created_at, :updated_at
json.url product_url(product, format: :json)
