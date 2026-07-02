class RemoveMatricFromOrders < ActiveRecord::Migration[8.1]
  def change
    remove_column :orders, :matric, :string
  end
end
