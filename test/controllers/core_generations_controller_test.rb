require "test_helper"

class CoreGenerationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get core_generations_new_url
    assert_response :success
  end

  test "should get create" do
    get core_generations_create_url
    assert_response :success
  end

  test "should get show" do
    get core_generations_show_url
    assert_response :success
  end
end
