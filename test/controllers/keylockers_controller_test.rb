require "test_helper"

class KeylockersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @keylocker = keylockers(:one)
  end

  test "should get index" do
    get keylockers_url
    assert_response :success
  end

  test "should get new" do
    get new_keylocker_url
    assert_response :success
  end

  test "should create keylocker" do
    assert_difference("Keylocker.count") do
      post keylockers_url, params: { keylocker: { ipAddress: @keylocker.ipAddress, nameDevice: @keylocker.nameDevice, owner: @keylocker.owner, status: @keylocker.status } }
    end

    assert_redirected_to keylocker_url(Keylocker.last)
  end

  test "should show keylocker" do
    get keylocker_url(@keylocker)
    assert_response :success
  end

  test "should get edit" do
    get edit_keylocker_url(@keylocker)
    assert_response :success
  end

  test "should update keylocker" do
    patch keylocker_url(@keylocker), params: { keylocker: { ipAddress: @keylocker.ipAddress, nameDevice: @keylocker.nameDevice, owner: @keylocker.owner, status: @keylocker.status } }
    assert_redirected_to keylocker_url(@keylocker)
  end

  test "should destroy keylocker" do
    assert_difference("Keylocker.count", -1) do
      delete keylocker_url(@keylocker)
    end

    assert_redirected_to keylockers_url
  end
end
