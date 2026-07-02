class Admin::PickupController < Admin::BaseController
  def index
    if params[:q].present?
      query = "%#{params[:q]}%"
      @orders = Order.paid.where("reference LIKE ? OR student_name LIKE ? OR phone LIKE ?", query, query, query).order(created_at: :desc)
    else
      @orders = Order.uncollected.order(created_at: :desc)
    end
  end

  def collect
    @order = Order.find(params[:id])
    @order.update!(status: "collected")
    redirect_to admin_pickup_path, notice: "Marked as collected"
  end
end
