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
end
