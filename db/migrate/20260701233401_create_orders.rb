class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :reference
      t.string :student_name
      t.string :matric
      t.string :phone
      t.string :email
      t.integer :total_amount
      t.string :payment_status
      t.string :status

      t.timestamps
    end
    add_index :orders, :reference, unique: true
  end
end
