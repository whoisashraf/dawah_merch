class Admin::ProductionController < Admin::BaseController
  def index
    @summary = {}
    products = Product.all.select { |p| p.has_options? && p.options.any? { |o| o["name"] == "Size" } }
    products.each do |product|
      size_option = product.options.find { |o| o["name"] == "Size" }
      sizes = {}
      size_option["values"].each do |size|
        count = OrderItem.joins(:order)
          .where(product: product, orders: { payment_status: "paid" })
          .where(selected_options: { Size: size })
          .sum(:quantity)
        sizes[size] = count if count > 0
      end
      @summary[product] = sizes
    end
  end
end
