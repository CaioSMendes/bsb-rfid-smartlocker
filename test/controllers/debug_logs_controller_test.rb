require "test_helper"

class DebugLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get debug_logs_index_url
    assert_response :success
  end
end
