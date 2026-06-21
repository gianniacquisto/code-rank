require "test_helper"

class StarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @technology = technologies(:react)  # no existing stars in fixtures
    login_as(@user)
  end

  test "should star a technology" do
    assert_difference -> { @technology.stars.count }, 1 do
      post technology_stars_path(technology_id: @technology.id), as: :turbo_stream
    end
  end

  test "should not star twice" do
    post technology_stars_path(technology_id: @technology.id), as: :turbo_stream
    assert_no_difference -> { @technology.stars.count } do
      post technology_stars_path(technology_id: @technology.id), as: :turbo_stream
    end
  end

  test "should unstar a technology" do
    @technology.stars.create!(user: @user, starred: true)
    assert_difference -> { @technology.stars.count }, -1 do
      delete technology_unstar_star_path(technology_id: @technology.id), as: :turbo_stream
    end
  end

  test "should return turbo_stream format" do
    post technology_stars_path(technology_id: @technology.id), as: :turbo_stream
    assert_response :success
    assert response.content_type.start_with?("text/vnd.turbo-stream")
  end

  test "should redirect non-turbo request" do
    post technology_stars_path(technology_id: @technology.id), as: :html
    assert_redirected_to root_path
  end

  test "should not star without authentication" do
    logout
    assert_no_difference -> { @technology.stars.count } do
      post technology_stars_path(technology_id: @technology.id)
    end
  end
end
