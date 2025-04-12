class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date_range, only: [:dashboard, :sales_report, :inventory_report, :financial_report]

  def dashboard
    @sales_data = calculate_sales_data
    @inventory_data = calculate_inventory_data
    @financial_data = calculate_financial_data
    @top_products = calculate_top_products
    @top_clients = calculate_top_clients
  end

  def sales_report
    @sales_data = calculate_sales_data
    respond_to do |format|
      format.html
      format.json { render json: @sales_data }
      format.csv { send_data generate_sales_csv, filename: "sales-report-#{Date.today}.csv" }
    end
  end

  def inventory_report
    @inventory_data = calculate_inventory_data
    respond_to do |format|
      format.html
      format.json { render json: @inventory_data }
      format.csv { send_data generate_inventory_csv, filename: "inventory-report-#{Date.today}.csv" }
    end
  end

  def financial_report
    @financial_data = calculate_financial_data
    respond_to do |format|
      format.html
      format.json { render json: @financial_data }
      format.csv { send_data generate_financial_csv, filename: "financial-report-#{Date.today}.csv" }
    end
  end

  def custom_report
    @report_type = params[:report_type]
    @custom_data = calculate_custom_data
    respond_to do |format|
      format.html
      format.json { render json: @custom_data }
      format.csv { send_data generate_custom_csv, filename: "custom-report-#{Date.today}.csv" }
    end
  end

  private

  def set_date_range
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 30.days.ago
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
  end

  def calculate_sales_data
    {
      total_sales: Order.where(created_at: @start_date..@end_date).sum(:total_price),
      sales_by_day: Order.where(created_at: @start_date..@end_date)
                        .group_by_day(:created_at)
                        .sum(:total_price),
      sales_by_product: OrderItem.joins(:order)
                                .where(orders: { created_at: @start_date..@end_date })
                                .group(:product_id)
                                .sum(:quantity)
    }
  end

  def calculate_inventory_data
    {
      total_inventory: Product.sum(:stock),
      low_stock_items: Product.where('stock < ?', 10),
      inventory_turnover: calculate_inventory_turnover
    }
  end

  def calculate_financial_data
    {
      total_income: Income.where(date: @start_date..@end_date).sum(:amount),
      total_expenses: Expense.where(date: @start_date..@end_date).sum(:amount),
      net_income: calculate_net_income,
      expenses_by_category: Expense.where(date: @start_date..@end_date)
                                 .group(:category)
                                 .sum(:amount)
    }
  end

  def calculate_top_products(limit = 5)
    Product.joins(:order_items)
           .group('products.id')
           .order('SUM(order_items.quantity) DESC')
           .limit(limit)
  end

  def calculate_top_clients(limit = 5)
    Client.joins(:orders)
          .where(orders: { created_at: @start_date..@end_date })
          .group('clients.id')
          .order('SUM(orders.total_price) DESC')
          .limit(limit)
  end

  def calculate_inventory_turnover
    # Implement inventory turnover calculation
    # This is a placeholder - you'll need to implement the actual calculation
    {}
  end

  def calculate_net_income
    total_income = Income.where(date: @start_date..@end_date).sum(:amount)
    total_expenses = Expense.where(date: @start_date..@end_date).sum(:amount)
    total_income - total_expenses
  end

  def generate_sales_csv
    CSV.generate do |csv|
      csv << ['Date', 'Total Sales']
      @sales_data[:sales_by_day].each do |date, amount|
        csv << [date, amount]
      end
    end
  end

  def generate_inventory_csv
    CSV.generate do |csv|
      csv << ['Product', 'Stock', 'Status']
      @inventory_data[:low_stock_items].each do |product|
        csv << [product.name, product.stock, product.stock < 10 ? 'Low' : 'OK']
      end
    end
  end

  def generate_financial_csv
    CSV.generate do |csv|
      csv << ['Category', 'Amount']
      @financial_data[:expenses_by_category].each do |category, amount|
        csv << [category, amount]
      end
    end
  end

  def generate_custom_csv
    # Implement custom CSV generation based on report type
    CSV.generate do |csv|
      # Add your custom CSV generation logic here
    end
  end
end 