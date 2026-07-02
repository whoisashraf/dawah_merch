class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, :subtotal, numericality: { greater_than_or_equal_to: 0 }
  validates :size, inclusion: { in: Product::SIZES }, allow_nil: true, if: -> { product&.has_sizes? }

  scope :with_custom_name, -> { where.not(custom_name: nil) }
  scope :pending_proofread, -> { where(custom_name_approved: nil).with_custom_name }
  scope :approved_names, -> { where(custom_name_approved: true) }
  scope :rejected_names, -> { where(custom_name_approved: false) }

  def proofread_status
    return "Pending" if custom_name_approved.nil?
    custom_name_approved ? "Approved" : "Rejected"
  end
end
