require "test_helper"

class OutputsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get outputs_create_url
    assert_response :success
  end

  test "should get new" do
    get outputs_new_url
    assert_response :success
  end
end
