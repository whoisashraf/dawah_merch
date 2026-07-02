class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, :subtotal, numericality: { greater_than_or_equal_to: 0 }
  validates :size, inclusion: { in: Product::SIZES }, allow_nil: true, if: -> { product&.has_sizes? }
  validate :product_must_be_active, on: :create
  validate :selected_options_must_be_valid, if: -> { product.present? }

  scope :with_custom_name, -> { where.not(custom_name: nil) }
  scope :pending_proofread, -> { where(custom_name_approved: nil).with_custom_name }
  scope :approved_names, -> { where(custom_name_approved: true) }
  scope :rejected_names, -> { where(custom_name_approved: false) }

  def proofread_status
    return "Pending" if custom_name_approved.nil?
    custom_name_approved ? "Approved" : "Rejected"
  end

  private

  def product_must_be_active
    if product.nil? || !product.active?
      errors.add(:product, "is not available")
    end
  end

  def selected_options_must_be_valid
    product_options = product.options || []
    
    product_options.each do |opt|
      opt_name = opt["name"]
      selected_val = selected_options&.[](opt_name)
      if selected_val.blank?
        errors.add(:selected_options, "missing selection for #{opt_name}")
      elsif !opt["values"].include?(selected_val)
        errors.add(:selected_options, "invalid selection '#{selected_val}' for #{opt_name}")
      end
    end
  end
end
