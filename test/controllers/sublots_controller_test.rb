require "test_helper"

class SublotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sublot = sublots(:one)
  end

  test "should get index" do
    get sublots_url
    assert_response :success
  end

  test "should get new" do
    get new_sublot_url
    assert_response :success
  end

  test "should create sublot" do
    assert_difference("Sublot.count") do
      post sublots_url, params: { sublot: { lot_id: @sublot.lot_id, name: @sublot.name, position: @sublot.position } }
    end

    assert_redirected_to sublot_url(Sublot.last)
  end

  test "should show sublot" do
    get sublot_url(@sublot)
    assert_response :success
  end

  test "should get edit" do
    get edit_sublot_url(@sublot)
    assert_response :success
  end

  test "should update sublot" do
    patch sublot_url(@sublot), params: { sublot: { lot_id: @sublot.lot_id, name: @sublot.name, position: @sublot.position } }
    assert_redirected_to sublot_url(@sublot)
  end

  test "should destroy sublot" do
    assert_difference("Sublot.count", -1) do
      delete sublot_url(@sublot)
    end

    assert_redirected_to sublots_url
  end
end
