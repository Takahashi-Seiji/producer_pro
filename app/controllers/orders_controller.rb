class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show edit update destroy ]

  # GET /orders or /orders.json
  def index
    @orders = Order.includes(:client)
    
    if params[:search].present?
      @orders = @orders.joins(:client).where("clients.name ILIKE ?", "%#{params[:search]}%")
    end
    
    if params[:status].present?
      @orders = @orders.where(status: params[:status])
    end
    
    if params[:start_date].present?
      @orders = @orders.where("delivery_date >= ?", params[:start_date])
    end
    
    if params[:end_date].present?
      @orders = @orders.where("delivery_date <= ?", params[:end_date])
    end
    
    @orders = @orders.order(created_at: :desc)
  end

  # GET /orders/1 or /orders/1.json
  def show
    @order = Order.includes(:client, order_items: :product).find(params[:id])
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.order_items.build
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders or /orders.json
  def create
    @order = Order.new(order_params)
    @order.total_price = @order.order_items.sum { |item| item.quantity * item.unit_price }

    respond_to do |format|
      if @order.save
        format.html { redirect_to order_url(@order), notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to order_url(@order), notice: "Order was successfully updated." }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    @order.destroy!

    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: [
          turbo_stream.remove(@order),
          turbo_stream.update("flash", partial: "shared/flash", locals: { flash: { notice: "Order was successfully destroyed." } })
        ]
      }
      format.html { redirect_to dashboard_orders_url, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.includes(:client, order_items: :product).find_by(id: params[:id])
      redirect_to dashboard_orders_url, alert: "Order not found." unless @order
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(
        :client_id, :status, :delivery_date, :notes,
        order_items_attributes: [:id, :product_id, :quantity, :unit_price, :_destroy]
      )
    end
end
