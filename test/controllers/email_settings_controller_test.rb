require "test_helper"

class EmailSettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get email_settings_new_url
    assert_response :success
  end

  test "should get create" do
    get email_settings_create_url
    assert_response :success
  end
end
