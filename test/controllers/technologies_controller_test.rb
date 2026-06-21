require "test_helper"

class TechnologiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get technologies_path
    assert_response :success
  end
end
