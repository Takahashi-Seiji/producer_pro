require "application_system_test_case"

class RawMaterialsTest < ApplicationSystemTestCase
  setup do
    @raw_material = raw_materials(:one)
  end

  test "visiting the index" do
    visit raw_materials_url
    assert_selector "h1", text: "Raw materials"
  end

  test "should create raw material" do
    visit raw_materials_url
    click_on "New raw material"

    fill_in "Cost per unit", with: @raw_material.cost_per_unit
    fill_in "Name", with: @raw_material.name
    fill_in "Stock", with: @raw_material.stock
    fill_in "Unit", with: @raw_material.unit
    click_on "Create Raw material"

    assert_text "Raw material was successfully created"
    click_on "Back"
  end

  test "should update Raw material" do
    visit raw_material_url(@raw_material)
    click_on "Edit this raw material", match: :first

    fill_in "Cost per unit", with: @raw_material.cost_per_unit
    fill_in "Name", with: @raw_material.name
    fill_in "Stock", with: @raw_material.stock
    fill_in "Unit", with: @raw_material.unit
    click_on "Update Raw material"

    assert_text "Raw material was successfully updated"
    click_on "Back"
  end

  test "should destroy Raw material" do
    visit raw_material_url(@raw_material)
    click_on "Destroy this raw material", match: :first

    assert_text "Raw material was successfully destroyed"
  end
end
