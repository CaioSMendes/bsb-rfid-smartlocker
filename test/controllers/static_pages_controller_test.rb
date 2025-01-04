require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get inadimplente" do
    get static_pages_inadimplente_url
    assert_response :success
  end
end
