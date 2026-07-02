class AddOptionsToProductsAndOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :options, :json, default: []
    add_column :order_items, :selected_options, :json, default: {}
  end
end
