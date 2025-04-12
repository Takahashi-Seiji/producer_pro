class Analytics::DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @start_date = params[:start_date] || 30.days.ago.to_date
    @end_date = params[:end_date] || Date.today

    # Sales data
    @sales_data = {
      total_sales: Order.where(created_at: @start_date..@end_date).sum(:total_price),
      sales_by_day: Order.where(created_at: @start_date..@end_date)
                        .group("DATE(created_at)")
                        .sum(:total_price)
                        .transform_keys { |date| date.to_date }
    }

    # Inventory data
    @inventory_data = {
      total_inventory: Product.sum(:stock),
      low_stock_items: Product.where('stock < 10').count,
      inventory_value: Product.sum('stock * price_per_unit')
    }

    # Financial data
    @financial_data = {
      total_income: Income.where(date: @start_date..@end_date).sum(:amount),
      total_expenses: Expense.where(date: @start_date..@end_date).sum(:amount),
      net_income: Income.where(date: @start_date..@end_date).sum(:amount) - 
                 Expense.where(date: @start_date..@end_date).sum(:amount),
      expenses_by_category: Expense.where(date: @start_date..@end_date)
                                 .group(:category)
                                 .sum(:amount)
    }

    # Top products and clients
    @top_products = Product.joins(order_items: :order)
                          .where(orders: { created_at: @start_date..@end_date })
                          .group('products.id')
                          .order('SUM(order_items.quantity) DESC')
                          .limit(5)

    @top_clients = Client.joins(:orders)
                        .where(orders: { created_at: @start_date..@end_date })
                        .group('clients.id')
                        .order('SUM(orders.total_price) DESC')
                        .limit(5)
  end

  def sales_report
    @start_date = params[:start_date] || 30.days.ago.to_date
    @end_date = params[:end_date] || Date.today

    @sales_data = {
      total_sales: Order.where(created_at: @start_date..@end_date).sum(:total_price),
      sales_by_day: Order.where(created_at: @start_date..@end_date)
                        .group("DATE(created_at)")
                        .sum(:total_price)
                        .transform_keys { |date| date.to_date },
      sales_by_product: OrderItem.joins(:order, :product)
                               .where(orders: { created_at: @start_date..@end_date })
                               .group('products.name')
                               .sum('order_items.quantity * order_items.price_per_unit')
    }

    respond_to do |format|
      format.html
      format.json { render json: @sales_data }
      format.csv do
        send_data generate_sales_csv(@sales_data), filename: "sales_report_#{@start_date}_to_#{@end_date}.csv"
      end
    end
  end

  def inventory_report
    @inventory_data = {
      total_inventory: Product.sum(:stock),
      low_stock_items: Product.where('stock < 10').count,
      inventory_by_category: Product.group(:category).sum(:stock),
      inventory_value: Product.sum('stock * price_per_unit')
    }

    respond_to do |format|
      format.html
      format.json { render json: @inventory_data }
      format.csv do
        send_data generate_inventory_csv(@inventory_data), filename: "inventory_report_#{Date.today}.csv"
      end
    end
  end

  def financial_report
    @start_date = params[:start_date] || 30.days.ago.to_date
    @end_date = params[:end_date] || Date.today

    @financial_data = {
      total_income: Income.where(date: @start_date..@end_date).sum(:amount),
      total_expenses: Expense.where(date: @start_date..@end_date).sum(:amount),
      net_income: Income.where(date: @start_date..@end_date).sum(:amount) - 
                 Expense.where(date: @start_date..@end_date).sum(:amount),
      income_by_source: Income.where(date: @start_date..@end_date)
                            .group(:source)
                            .sum(:amount),
      expenses_by_category: Expense.where(date: @start_date..@end_date)
                                 .group(:category)
                                 .sum(:amount)
    }

    respond_to do |format|
      format.html
      format.json { render json: @financial_data }
      format.csv do
        send_data generate_financial_csv(@financial_data), filename: "financial_report_#{@start_date}_to_#{@end_date}.csv"
      end
    end
  end

  def custom_report
    @report_type = params[:type]
    @start_date = params[:start_date] || 30.days.ago.to_date
    @end_date = params[:end_date] || Date.today

    case @report_type
    when 'sales_by_client'
      @data = Order.joins(:client)
                  .where(created_at: @start_date..@end_date)
                  .group('clients.name')
                  .sum(:total_price)
    when 'product_performance'
      @data = Product.joins(:order_items)
                    .where(orders: { created_at: @start_date..@end_date })
                    .group('products.name')
                    .select('products.*, SUM(order_items.quantity) as total_sold')
    else
      @data = {}
    end

    respond_to do |format|
      format.html
      format.json { render json: @data }
      format.csv do
        send_data generate_custom_csv(@data, @report_type), 
                 filename: "#{@report_type}_report_#{@start_date}_to_#{@end_date}.csv"
      end
    end
  end

  private

  def generate_sales_csv(data)
    CSV.generate do |csv|
      csv << ['Sales Report', "#{@start_date} to #{@end_date}"]
      csv << []
      csv << ['Total Sales', number_to_currency(data[:total_sales])]
      csv << []
      csv << ['Date', 'Sales']
      data[:sales_by_day].each do |date, amount|
        csv << [date, number_to_currency(amount)]
      end
      csv << []
      csv << ['Product', 'Sales']
      data[:sales_by_product].each do |product, amount|
        csv << [product, number_to_currency(amount)]
      end
    end
  end

  def generate_inventory_csv(data)
    CSV.generate do |csv|
      csv << ['Inventory Report', Date.today]
      csv << []
      csv << ['Total Inventory', data[:total_inventory]]
      csv << ['Low Stock Items', data[:low_stock_items]]
      csv << ['Total Inventory Value', number_to_currency(data[:inventory_value])]
      csv << []
      csv << ['Category', 'Quantity']
      data[:inventory_by_category].each do |category, quantity|
        csv << [category, quantity]
      end
    end
  end

  def generate_financial_csv(data)
    CSV.generate do |csv|
      csv << ['Financial Report', "#{@start_date} to #{@end_date}"]
      csv << []
      csv << ['Total Income', number_to_currency(data[:total_income])]
      csv << ['Total Expenses', number_to_currency(data[:total_expenses])]
      csv << ['Net Income', number_to_currency(data[:net_income])]
      csv << []
      csv << ['Income Source', 'Amount']
      data[:income_by_source].each do |source, amount|
        csv << [source, number_to_currency(amount)]
      end
      csv << []
      csv << ['Expense Category', 'Amount']
      data[:expenses_by_category].each do |category, amount|
        csv << [category, number_to_currency(amount)]
      end
    end
  end

  def generate_custom_csv(data, report_type)
    CSV.generate do |csv|
      case report_type
      when 'sales_by_client'
        csv << ['Sales by Client Report', "#{@start_date} to #{@end_date}"]
        csv << []
        csv << ['Client', 'Total Sales']
        data.each do |client, amount|
          csv << [client, number_to_currency(amount)]
        end
      when 'product_performance'
        csv << ['Product Performance Report', "#{@start_date} to #{@end_date}"]
        csv << []
        csv << ['Product', 'Total Sold', 'Current Stock', 'Price per Unit']
        data.each do |product|
          csv << [product.name, product.total_sold, product.stock, number_to_currency(product.price_per_unit)]
        end
      end
    end
  end
end 