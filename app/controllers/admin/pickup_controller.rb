class Admin::PickupController < Admin::BaseController
  def index
    if params[:q].present?
      query = "%#{params[:q]}%"
      table = Order.arel_table
      @orders = Order.paid.where(
        table[:reference].matches(query)
          .or(table[:student_name].matches(query))
          .or(table[:phone].matches(query))
      ).order(created_at: :desc)
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
