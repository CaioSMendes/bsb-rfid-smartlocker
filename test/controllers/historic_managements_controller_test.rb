require "test_helper"

class HistoricManagementsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get historic_managements_index_url
    assert_response :success
  end

  test "should get show" do
    get historic_managements_show_url
    assert_response :success
  end
end
