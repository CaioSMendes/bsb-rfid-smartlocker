require "application_system_test_case"

class AssetManagementsTest < ApplicationSystemTestCase
  setup do
    @asset_management = asset_managements(:one)
  end

  test "visiting the index" do
    visit asset_managements_url
    assert_selector "h1", text: "Asset managements"
  end

  test "should create asset management" do
    visit asset_managements_url
    click_on "New asset management"

    fill_in "Description", with: @asset_management.description
    fill_in "Name", with: @asset_management.name
    click_on "Create Asset management"

    assert_text "Asset management was successfully created"
    click_on "Back"
  end

  test "should update Asset management" do
    visit asset_management_url(@asset_management)
    click_on "Edit this asset management", match: :first

    fill_in "Description", with: @asset_management.description
    fill_in "Name", with: @asset_management.name
    click_on "Update Asset management"

    assert_text "Asset management was successfully updated"
    click_on "Back"
  end

  test "should destroy Asset management" do
    visit asset_management_url(@asset_management)
    click_on "Destroy this asset management", match: :first

    assert_text "Asset management was successfully destroyed"
  end
end
