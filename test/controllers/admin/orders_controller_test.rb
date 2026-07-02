require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @user = users(:two)
    @order = orders(:one)
    @product = products(:one)
  end

  test "should get index when authenticated as admin" do
    sign_in_as(@admin)
    get admin_orders_url
    assert_response :success
  end

  test "should redirect to login when unauthenticated" do
    get admin_orders_url
    assert_redirected_to new_session_path
  end

  test "should redirect to root when authenticated as non-admin" do
    sign_in_as(@user)
    get admin_orders_url
    assert_redirected_to root_path
  end

  test "should get new offline order page" do
    sign_in_as(@admin)
    get new_admin_order_url
    assert_response :success
  end

  test "should create offline order" do
    sign_in_as(@admin)
    assert_difference "Order.count", 1 do
      assert_difference "OrderItem.count", 1 do
        post admin_orders_url, params: {
          order: {
            student_name: "Test Student",
            phone: "08033333333",
            email: "test@example.com",
            department: "Cyber Security",
            level: "400L",
            delivery_location: "hostel",
            order_items: {
              "0" => {
                product_id: @product.id,
                size: "L",
                quantity: "1",
                custom_name: "TEST"
              }
            }
          }
        }
      end
    end
    assert_redirected_to admin_order_url(Order.last)
    assert_equal "paid", Order.last.payment_status
    assert_equal "processing", Order.last.status
    assert_equal true, Order.last.order_items.first.custom_name_approved
  end

  test "should delete order" do
    sign_in_as(@admin)
    assert_difference "Order.count", -1 do
      delete admin_order_url(@order)
    end
    assert_redirected_to admin_orders_url
  end
end
