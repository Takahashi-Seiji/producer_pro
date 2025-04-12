json.extract! order, :id, :client_id, :status, :total_price, :delivery_date, :created_at, :updated_at
json.url order_url(order, format: :json)
