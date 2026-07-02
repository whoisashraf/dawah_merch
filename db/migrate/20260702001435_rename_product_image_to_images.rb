class RenameProductImageToImages < ActiveRecord::Migration[8.0]
  def up
    ActiveStorage::Attachment.where(record_type: "Product", name: "image").update_all(name: "images")
  end

  def down
    ActiveStorage::Attachment.where(record_type: "Product", name: "images").update_all(name: "image")
  end
end
