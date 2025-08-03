require "test_helper"

class KeylockerinfosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get keylockerinfos_index_url
    assert_response :success
  end

  test "should get show" do
    get keylockerinfos_show_url
    assert_response :success
  end
end
