class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  validates :reference, presence: true, uniqueness: true
  validates :student_name, :phone, :email, :department, :level, presence: true
  validates :delivery_location, inclusion: { in: %w[hostel off_campus] }
  validates :total_amount, numericality: { greater_than: 0 }
  validates :payment_status, inclusion: { in: %w[unpaid paid failed] }
  validates :status, inclusion: { in: %w[pending processing ready collected cancelled] }

  scope :paid, -> { where(payment_status: "paid") }
  scope :unpaid, -> { where(payment_status: "unpaid") }
  scope :processing, -> { where(status: "processing") }
  scope :ready_for_pickup, -> { where(status: "ready") }
  scope :uncollected, -> { where(status: %w[processing ready]) }
  scope :needs_proofread, -> { where(id: OrderItem.pending_proofread.select(:order_id)) }

  def build_order_items_from_params(items_params)
    items_params.each do |_, item|
      next if item[:quantity].to_i <= 0
      product = Product.find(item[:product_id])
      unit_price = product.base_price
      unit_price += product.custom_name_fee.to_i if product.has_custom_name? && item[:custom_name].present?

      order_items.build(
        product: product,
        size: item[:size],
        custom_name: item[:custom_name],
        selected_options: item[:selected_options],
        quantity: item[:quantity].to_i,
        unit_price: unit_price,
        subtotal: unit_price * item[:quantity].to_i
      )
    end
  end

  def calculate_total_from_params(items_params)
    total = 0
    items_params.each do |_, item|
      next if item[:quantity].to_i <= 0
      product = Product.find(item[:product_id])
      price = product.base_price
      price += product.custom_name_fee.to_i if product.has_custom_name? && item[:custom_name].present?
      total += price * item[:quantity].to_i
    end
    total
  end

  def options_summary(item)
    return "" unless item.selected_options.present?
    item.selected_options.values.join(", ")
  end

  def unpaid?
    payment_status == "unpaid"
  end

  def paid?
    payment_status == "paid"
  end

  def total_in_naira
    total_amount / 100.0
  end

  def self.total_revenue
    paid.sum(:total_amount)
  end

  def whatsapp_url
    cleaned = phone.delete("^0-9")
    cleaned = "234#{cleaned}" if cleaned.start_with?("0")
    lines = [
      "Dawah Week Order ##{reference}",
      "Name: #{student_name}",
      "Level: #{level}",
      "Dept: #{department}",
      "Phone: #{phone}",
      "Delivery: #{delivery_label}",
      "Items: #{items_summary}",
      "Total: NGN#{total_in_naira}"
    ]
    "https://wa.me/#{cleaned}?text=#{CGI.escape(lines.join("\n"))}"
  end

  def delivery_label
    case delivery_location
    when "hostel" then "Hostel (On Campus)"
    when "off_campus" then "Off Campus (GK)"
    else delivery_location
    end
  end

  def items_summary
    order_items.map { |i|
      parts = [i.product.name]
      if i.selected_options.present?
        parts << "(#{i.selected_options.values.join(', ')})"
      end
      parts << "-#{i.custom_name}" if i.custom_name.present?
      parts.join(" ")
    }.join(", ")
  end
end
