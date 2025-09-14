require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get sessions" do
    get api_v1_auth_sessions_url
    assert_response :success
  end

  test "should get registrations" do
    get api_v1_auth_registrations_url
    assert_response :success
  end
end
