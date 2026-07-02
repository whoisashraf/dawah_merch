class OrdersController < ApplicationController
  allow_unauthenticated_access only: %i[new create success]

  def new
    @products = Product.active.all
    @order = Order.new
  end

  def create
    items_params = order_items_params
    total = Order.new.calculate_total_from_params(items_params)

    @order = Order.new(order_params.merge(
      reference: "DW-#{Time.now.to_i}-#{SecureRandom.hex(4).upcase}",
      total_amount: total,
      payment_status: "unpaid",
      status: "pending"
    ))

    @order.build_order_items_from_params(items_params)

    if @order.save
      paystack = Paystack.new
      email = @order.email
      response = paystack.initialize_transaction(
        email: email,
        amount: total,
        reference: @order.reference,
        callback_url: order_success_url(@order.reference)
      )

      if response.body["status"]
        redirect_to response.body["data"]["authorization_url"], allow_other_host: true
      else
        @order.destroy!
        flash[:alert] = "Payment could not be processed. Please try again."
        redirect_to new_order_path
      end
    else
      @products = Product.active.all
      render :new, status: :unprocessable_entity
    end
  end

  def success
    @order = Order.find_by!(reference: params[:reference])
    @whatsapp_group_link = Setting.get("whatsapp_group_link")

    paystack = Paystack.new
    response = paystack.verify_transaction(@order.reference)

    if response.body["status"] && response.body["data"]["status"] == "success"
      @order.update(payment_status: "paid", status: "processing") if @order.unpaid?
      @verified = true
    else
      @verified = false
    end
  end

  private

  def order_params
    params.require(:order).permit(:student_name, :phone, :email, :department, :level, :delivery_location)
  end

  def order_items_params
    params.require(:order).permit(order_items: [:product_id, :size, :custom_name, :quantity, selected_options: {}])[:order_items] || {}
  end
end
