class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @clients = Client.includes(:orders)
    
    # Apply search filter if search parameter is present
    if params[:search].present?
      @clients = @clients.where("name ILIKE :search OR email ILIKE :search", search: "%#{params[:search]}%")
    end
    
    # Apply sorting
    @clients = case params[:sort]
      when 'name_asc'
        @clients.order(name: :asc)
      when 'name_desc'
        @clients.order(name: :desc)
      when 'orders_desc'
        @clients.left_joins(:orders)
               .group(:id)
               .order('COUNT(orders.id) DESC')
      when 'revenue_desc'
        @clients.left_joins(:orders)
               .group(:id)
               .order('SUM(orders.total_amount) DESC NULLS LAST')
      else
        @clients.order(created_at: :desc)
    end

    # Initialize recent orders
    @recent_orders = Order.includes(:client).order(created_at: :desc).limit(5)
    @low_stock_products = Product.where('stock < ?', 10).order(stock: :asc)
    @upcoming_deliveries = Order.includes(:client)
                              .where('delivery_date >= ?', Date.today)
                              .where('delivery_date <= ?', 5.days.from_now)
                              .order(delivery_date: :asc)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def calendar
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today.end_of_month

    @orders = Order.includes(:client)
                  .where(delivery_date: start_date..end_date)
                  .order(delivery_date: :asc)
    
    @upcoming_deliveries = Order.includes(:client)
                              .where('delivery_date >= ?', Date.today)
                              .where('delivery_date <= ?', 5.days.from_now)
                              .order(delivery_date: :asc)
  end
  
  def orders
    @orders = Order.includes(:client, :order_items).order(created_at: :desc)
    
    # Apply filters
    @orders = @orders.joins(:client).where("LOWER(clients.name) LIKE ?", "%#{params[:search].downcase}%") if params[:search].present?
    @orders = @orders.where(status: params[:status]) if params[:status].present?
    @orders = @orders.where("delivery_date >= ?", params[:start_date]) if params[:start_date].present?
    @orders = @orders.where("delivery_date <= ?", params[:end_date]) if params[:end_date].present?

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("orders_list", 
          partial: "dashboard/orders_table", 
          locals: { orders: @orders })
      end
    end
  end
  
  def inventory
    @products = Product.order(stock: :asc)
    @raw_materials = RawMaterial.order(stock: :asc)

    # Apply search filters
    if params[:search].present?
      case params[:section]
      when 'products'
        @products = @products.where('LOWER(name) LIKE :search OR LOWER(description) LIKE :search', 
          search: "%#{params[:search].downcase}%")
      when 'materials'
        @raw_materials = @raw_materials.where('LOWER(name) LIKE :search', 
          search: "%#{params[:search].downcase}%")
      end
    end

    respond_to do |format|
      format.html
      format.turbo_stream do
        if params[:section] == 'products'
          render turbo_stream: turbo_stream.update("products_list", 
            partial: "dashboard/products_table", 
            locals: { products: @products })
        else
          render turbo_stream: turbo_stream.update("materials_list", 
            partial: "dashboard/materials_table", 
            locals: { raw_materials: @raw_materials })
        end
      end
    end
  end
  
  def clients
    @clients = Client.includes(:orders)
    
    # Apply search filter if search parameter is present
    if params[:search].present?
      @clients = @clients.where("name ILIKE :search OR email ILIKE :search", search: "%#{params[:search]}%")
    end
    
    # Apply sorting
    @clients = case params[:sort]
      when 'name_asc'
        @clients.order(name: :asc)
      when 'name_desc'
        @clients.order(name: :desc)
      when 'orders_desc'
        @clients.left_joins(:orders)
               .group(:id)
               .order('COUNT(orders.id) DESC')
      when 'revenue_desc'
        @clients.left_joins(:orders)
               .group(:id)
               .order('SUM(orders.total_amount) DESC NULLS LAST')
      else
        @clients.order(created_at: :desc)
    end

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("clients_list", 
          partial: "dashboard/clients_table", 
          locals: { clients: @clients })
      end
    end
  end
  
  def finances
    @expenses = Expense.order(date: :desc)
    @incomes = Income.order(date: :desc)
    
    @total_expenses = @expenses.sum(:amount)
    @total_income = @incomes.sum(:amount)
    @net_income = @total_income - @total_expenses
  end
  
  def reports
    @best_clients = Client.joins(:orders)
                         .group('clients.id')
                         .order('SUM(orders.total_price) DESC')
                         .limit(5)
                         .select('clients.*, SUM(orders.total_price) as total_spent')
    
    @best_products = Product.joins(:order_items)
                           .group('products.id')
                           .order('SUM(order_items.quantity) DESC')
                           .limit(5)
                           .select('products.*, SUM(order_items.quantity) as total_sold')
    
    @monthly_income = Income.group_by_month(:date).sum(:amount)
    @monthly_expenses = Expense.group_by_month(:date).sum(:amount)
  end
end
