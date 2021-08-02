require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home--skip-test-framework" do
    get static_pages_home--skip-test-framework_url
    assert_response :success
  end
end
