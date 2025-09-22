require "test_helper"

class AssetManagementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @asset_management = asset_managements(:one)
  end

  test "should get index" do
    get asset_managements_url
    assert_response :success
  end

  test "should get new" do
    get new_asset_management_url
    assert_response :success
  end

  test "should create asset_management" do
    assert_difference("AssetManagement.count") do
      post asset_managements_url, params: { asset_management: { description: @asset_management.description, name: @asset_management.name } }
    end

    assert_redirected_to asset_management_url(AssetManagement.last)
  end

  test "should show asset_management" do
    get asset_management_url(@asset_management)
    assert_response :success
  end

  test "should get edit" do
    get edit_asset_management_url(@asset_management)
    assert_response :success
  end

  test "should update asset_management" do
    patch asset_management_url(@asset_management), params: { asset_management: { description: @asset_management.description, name: @asset_management.name } }
    assert_redirected_to asset_management_url(@asset_management)
  end

  test "should destroy asset_management" do
    assert_difference("AssetManagement.count", -1) do
      delete asset_management_url(@asset_management)
    end

    assert_redirected_to asset_managements_url
  end
end
