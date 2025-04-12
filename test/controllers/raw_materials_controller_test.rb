require "test_helper"

class RawMaterialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @raw_material = raw_materials(:one)
  end

  test "should get index" do
    get raw_materials_url
    assert_response :success
  end

  test "should get new" do
    get new_raw_material_url
    assert_response :success
  end

  test "should create raw_material" do
    assert_difference("RawMaterial.count") do
      post raw_materials_url, params: { raw_material: { cost_per_unit: @raw_material.cost_per_unit, name: @raw_material.name, stock: @raw_material.stock, unit: @raw_material.unit } }
    end

    assert_redirected_to raw_material_url(RawMaterial.last)
  end

  test "should show raw_material" do
    get raw_material_url(@raw_material)
    assert_response :success
  end

  test "should get edit" do
    get edit_raw_material_url(@raw_material)
    assert_response :success
  end

  test "should update raw_material" do
    patch raw_material_url(@raw_material), params: { raw_material: { cost_per_unit: @raw_material.cost_per_unit, name: @raw_material.name, stock: @raw_material.stock, unit: @raw_material.unit } }
    assert_redirected_to raw_material_url(@raw_material)
  end

  test "should destroy raw_material" do
    assert_difference("RawMaterial.count", -1) do
      delete raw_material_url(@raw_material)
    end

    assert_redirected_to raw_materials_url
  end
end
