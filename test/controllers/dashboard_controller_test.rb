require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboard_index_url
    assert_response :success
  end

  test "should get orders" do
    get dashboard_orders_url
    assert_response :success
  end

  test "should get inventory" do
    get dashboard_inventory_url
    assert_response :success
  end

  test "should get clients" do
    get dashboard_clients_url
    assert_response :success
  end

  test "should get finances" do
    get dashboard_finances_url
    assert_response :success
  end

  test "should get reports" do
    get dashboard_reports_url
    assert_response :success
  end
end
