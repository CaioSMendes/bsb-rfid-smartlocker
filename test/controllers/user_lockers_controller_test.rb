require "test_helper"

class UserLockersControllerTest < ActionDispatch::IntegrationTest
  test "should get assign_locker" do
    get user_lockers_assign_locker_url
    assert_response :success
  end

  test "should get remove_locker" do
    get user_lockers_remove_locker_url
    assert_response :success
  end
end
