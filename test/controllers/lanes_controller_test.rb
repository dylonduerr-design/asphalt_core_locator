require "test_helper"

class LanesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lane = lanes(:one)
  end

  test "should get index" do
    get lanes_url
    assert_response :success
  end

  test "should get new" do
    get new_lane_url
    assert_response :success
  end

  test "should create lane" do
    assert_difference("Lane.count") do
      post lanes_url, params: { lane: { length_ft: @lane.length_ft, name: @lane.name, position: @lane.position, sublot_id: @lane.sublot_id, width_ft: @lane.width_ft } }
    end

    assert_redirected_to lane_url(Lane.last)
  end

  test "should show lane" do
    get lane_url(@lane)
    assert_response :success
  end

  test "should get edit" do
    get edit_lane_url(@lane)
    assert_response :success
  end

  test "should update lane" do
    patch lane_url(@lane), params: { lane: { length_ft: @lane.length_ft, name: @lane.name, position: @lane.position, sublot_id: @lane.sublot_id, width_ft: @lane.width_ft } }
    assert_redirected_to lane_url(@lane)
  end

  test "should destroy lane" do
    assert_difference("Lane.count", -1) do
      delete lane_url(@lane)
    end

    assert_redirected_to lanes_url
  end
end
