require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
  end

  test "should get index" do
    get items_url
    assert_response :success
  end

  test "should get new" do
    get new_item_url
    assert_response :success
  end

  test "should create item" do
    assert_difference("Item.count") do
      post items_url, params: { item: { asset_management_id: @item.asset_management_id, category_id: @item.category_id, location_id: @item.location_id, notes: @item.notes, rfid_tag: @item.rfid_tag, serial_number: @item.serial_number, status: @item.status } }
    end

    assert_redirected_to item_url(Item.last)
  end

  test "should show item" do
    get item_url(@item)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_url(@item)
    assert_response :success
  end

  test "should update item" do
    patch item_url(@item), params: { item: { asset_management_id: @item.asset_management_id, category_id: @item.category_id, location_id: @item.location_id, notes: @item.notes, rfid_tag: @item.rfid_tag, serial_number: @item.serial_number, status: @item.status } }
    assert_redirected_to item_url(@item)
  end

  test "should destroy item" do
    assert_difference("Item.count", -1) do
      delete item_url(@item)
    end

    assert_redirected_to items_url
  end
end
