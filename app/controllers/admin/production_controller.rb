class Admin::ProductionController < Admin::BaseController
  def index
    @summary = {}
    products = Product.all.select { |p| p.has_options? && p.options.any? { |o| o["name"] == "Size" } }
    
    if products.any?
      # Fetch all paid order items for these products in a single database query
      all_items = OrderItem.joins(:order)
        .where(product_id: products.map(&:id), orders: { payment_status: "paid" })
        .includes(:product)
        .to_a

      products.each do |product|
        product_items = all_items.select { |item| item.product_id == product.id }
        size_option = product.options.find { |o| o["name"] == "Size" }
        sizes = {}
        
        size_option["values"].each do |size|
          count = product_items.select { |item| item.selected_options.present? && item.selected_options["Size"] == size }
                               .sum(&:quantity)
          sizes[size] = count if count > 0
        end
        @summary[product] = sizes
      end
    end
  end
end
