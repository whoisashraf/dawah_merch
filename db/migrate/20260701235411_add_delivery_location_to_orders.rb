class AddDeliveryLocationToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :delivery_location, :string
  end
end
