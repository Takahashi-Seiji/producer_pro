class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  # GET /clients or /clients.json
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

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /clients/1 or /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients or /clients.json
  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to @client, notice: 'Client was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    if @client.update(client_params)
      redirect_to @client, notice: 'Client was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    @client.destroy
    redirect_to clients_url, notice: 'Client was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.require(:client).permit(:name, :email, :phone, :address)
    end
end
