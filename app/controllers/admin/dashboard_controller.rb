class Admin::DashboardController < Admin::BaseController
  def index
    @paid_orders = Order.paid.count
    @total_revenue = Order.total_revenue
    @pending_proofread = OrderItem.pending_proofread.count
    @uncollected = Order.uncollected.count
    @products_count = Product.active.count
    @recent_orders = Order.paid.order(created_at: :desc).limit(5)
  end
end
