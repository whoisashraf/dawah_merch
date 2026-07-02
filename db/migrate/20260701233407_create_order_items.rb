class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :size
      t.text :custom_name
      t.boolean :custom_name_approved
      t.integer :quantity
      t.integer :unit_price
      t.integer :subtotal

      t.timestamps
    end
  end
end
