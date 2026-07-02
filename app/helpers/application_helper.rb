module ApplicationHelper
  def product_icon(product)
    case product.slug
    when "hoodie" then "🧥"
    when "sweatshirt" then "👕"
    when "tote-bag" then "🛍️"
    when "notebook" then "📓"
    when "water-bottle" then "🧴"
    else "📦"
    end
  end

  def naira(amount)
    "₦#{number_with_delimiter(amount / 100)}"
  end
end
