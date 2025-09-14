require "test_helper"

class Api::V1::SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get jobs" do
    get api_v1_search_jobs_url
    assert_response :success
  end

  test "should get companies" do
    get api_v1_search_companies_url
    assert_response :success
  end

  test "should get job_seekers" do
    get api_v1_search_job_seekers_url
    assert_response :success
  end
end
