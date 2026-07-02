class Admin::OrdersController < Admin::BaseController
  def index
    @orders = if params[:payment_status] == "all" || params[:status].present?
      Order.order(created_at: :desc)
    else
      Order.order(created_at: :desc).paid
    end
    @orders = @orders.where(payment_status: params[:payment_status]) if params[:payment_status].present? && params[:payment_status] != "all"
    @orders = @orders.where(status: params[:status]) if params[:status].present?

    @pending_proofread_items = OrderItem.pending_proofread.includes(:order, :product).order(created_at: :asc) if params[:pending_proofread].present?
  end

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
    @products = Product.active.all
  end

  def create
    items_params = order_items_params
    total = Order.new.calculate_total_from_params(items_params)

    @order = Order.new(order_params.merge(
      reference: "DW-OFFLINE-#{Time.now.to_i}-#{SecureRandom.hex(3).upcase}",
      total_amount: total,
      payment_status: "paid",
      status: "processing"
    ))

    @order.build_order_items_from_params(items_params)

    # Offline order custom names are approved by default since admin creates them
    @order.order_items.each do |item|
      item.custom_name_approved = true if item.custom_name.present?
    end

    if @order.save
      redirect_to admin_order_path(@order), notice: "Offline order created successfully."
    else
      @products = Product.active.all
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to admin_orders_path, notice: "Order deleted successfully.", status: :see_other
  end

  private

  def order_params
    params.require(:order).permit(:student_name, :phone, :email, :department, :level, :delivery_location)
  end

  def order_items_params
    params.require(:order).permit(order_items: [:product_id, :size, :custom_name, :quantity, selected_options: {}])[:order_items] || {}
  end
end
