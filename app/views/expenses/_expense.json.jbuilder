json.extract! expense, :id, :name, :amount, :date, :category, :notes, :created_at, :updated_at
json.url expense_url(expense, format: :json)
