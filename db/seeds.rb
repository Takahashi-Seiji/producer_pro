# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create a test user
user = User.create!(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password'
)

# Create sample raw materials
raw_materials = [
  { name: 'Flour', stock: 1000, unit: 'kg', cost_per_unit: 0.5 },
  { name: 'Sugar', stock: 500, unit: 'kg', cost_per_unit: 0.8 },
  { name: 'Eggs', stock: 200, unit: 'dozen', cost_per_unit: 2.5 },
  { name: 'Butter', stock: 300, unit: 'kg', cost_per_unit: 3.0 },
  { name: 'Milk', stock: 200, unit: 'liters', cost_per_unit: 1.2 }
]

raw_materials.each do |material|
  RawMaterial.create!(material)
end

# Create sample products
products = [
  { name: 'Bread', stock: 50, unit: 'loaf', price_per_unit: 3.5, description: 'Freshly baked bread' },
  { name: 'Croissant', stock: 30, unit: 'piece', price_per_unit: 2.0, description: 'Buttery croissant' },
  { name: 'Cake', stock: 20, unit: 'piece', price_per_unit: 15.0, description: 'Delicious cake' },
  { name: 'Cookies', stock: 100, unit: 'dozen', price_per_unit: 8.0, description: 'Homemade cookies' },
  { name: 'Muffins', stock: 40, unit: 'piece', price_per_unit: 2.5, description: 'Fresh muffins' }
]

products.each do |product|
  Product.create!(product)
end

# Create sample clients
clients = [
  { name: 'John Smith', email: 'john@example.com', phone: '123-456-7890', address: '123 Main St', notes: 'Regular customer' },
  { name: 'Sarah Johnson', email: 'sarah@example.com', phone: '234-567-8901', address: '456 Oak Ave', notes: 'Prefers gluten-free options' },
  { name: 'Mike Brown', email: 'mike@example.com', phone: '345-678-9012', address: '789 Pine St', notes: 'Bulk orders' },
  { name: 'Emily Davis', email: 'emily@example.com', phone: '456-789-0123', address: '321 Elm St', notes: 'New customer' },
  { name: 'David Wilson', email: 'david@example.com', phone: '567-890-1234', address: '654 Maple Ave', notes: 'Corporate orders' }
]

clients.each do |client|
  Client.create!(client)
end

# Create sample orders spread across the last 30 days
clients = Client.all
products = Product.all

# Create 30 sample orders (1 per day on average)
30.times do |i|
  client = clients.sample
  order = Order.create!(
    client: client,
    status: ['pending', 'confirmed', 'delivered'].sample,
    total_price: 0,
    delivery_date: rand(1..7).days.from_now,
    created_at: (30 - i).days.ago # This spreads orders across the last 30 days
  )

  # Add 1-5 random products to each order
  total_price = 0
  rand(1..5).times do
    product = products.sample
    quantity = rand(1..10)
    unit_price = product.price_per_unit
    total_price += quantity * unit_price
    
    OrderItem.create!(
      order: order,
      product: product,
      quantity: quantity,
      unit_price: unit_price
    )
  end
  
  # Update the order's total price
  order.update!(total_price: total_price)
end

# Create sample expenses
expense_categories = ['Ingredients', 'Equipment', 'Utilities', 'Rent', 'Marketing', 'Salaries']
30.times do |i|
  Expense.create!(
    name: "Expense #{rand(1000..9999)}",
    amount: rand(100..1000),
    date: (30 - i).days.ago,
    category: expense_categories.sample,
    notes: "Sample expense note #{rand(1000..9999)}"
  )
end

# Create sample income
income_sources = ['Sales', 'Catering', 'Wholesale', 'Events', 'Online Orders']
30.times do |i|
  Income.create!(
    amount: rand(500..2000),
    date: (30 - i).days.ago,
    source: income_sources.sample,
    notes: "Sample income note #{rand(1000..9999)}"
  )
end

puts "Seed data created successfully!"
