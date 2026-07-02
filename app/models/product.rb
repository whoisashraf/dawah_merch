class Product < ApplicationRecord
  has_many_attached :images
  has_many :order_items, dependent: :restrict_with_error

  before_validation :generate_slug, on: :create

  validates :name, :base_price, presence: true
  validates :slug, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :base_price, numericality: { greater_than: 0 }
  validates :custom_name_fee, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(active: true) }

  SIZES = %w[XXL XL L].freeze

  def has_options?
    options.present? && options.any?
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present? && slug.blank?
  end
end
