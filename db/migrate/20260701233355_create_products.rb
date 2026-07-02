class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :slug
      t.integer :base_price
      t.boolean :has_sizes
      t.boolean :has_custom_name
      t.integer :custom_name_fee
      t.boolean :active

      t.timestamps
    end
    add_index :products, :slug, unique: true
  end
end
