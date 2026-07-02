class Admin::ProofreadController < Admin::BaseController
  def index
    @order_items = OrderItem.pending_proofread.includes(:order, :product).order(created_at: :asc)
  end

  def approve
    @order_item = OrderItem.find(params[:id])
    @order_item.update!(custom_name_approved: true)
    redirect_to admin_proofread_index_path, notice: "Custom name approved"
  end

  def reject
    @order_item = OrderItem.find(params[:id])
    @order_item.update!(custom_name_approved: false)
    redirect_to admin_proofread_index_path, notice: "Custom name rejected"
  end
end
