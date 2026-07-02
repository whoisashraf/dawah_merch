class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @products = Product.order(created_at: :desc)
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to admin_products_path, notice: "Product created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:remove_image_ids].present?
      @product.images.where(id: params[:remove_image_ids]).purge
    end
    if @product.update(product_params)
      redirect_to admin_products_path, notice: "Product updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy
      redirect_to admin_products_path, notice: "Product deleted", status: :see_other
    else
      redirect_to edit_admin_product_path(@product), alert: @product.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    p = params.require(:product).permit(:name, :base_price, :active, :has_sizes, :has_custom_name, :custom_name_fee, images: [])
    p.delete(:images) if p[:images].all?(&:blank?)
    p[:base_price] = p[:base_price].to_i * 100 if p[:base_price].present?
    p[:custom_name_fee] = p[:custom_name_fee].to_i * 100 if p[:custom_name_fee].present?

    if params[:product][:options_config].present?
      p[:options] = params[:product][:options_config].values.map { |o|
        next if o[:name].blank?
        { "name" => o[:name], "values" => o[:values].split(",").map(&:strip) }
      }.compact
    end

    p
  end
end
