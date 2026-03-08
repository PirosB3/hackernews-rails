require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "login page renders" do
    get login_path
    assert_response :success
  end

  test "login with valid credentials" do
    post login_path, params: { username: "alice", password: "password123" }
    assert_redirected_to root_path
    follow_redirect!
    assert_match "alice", response.body
  end

  test "login with invalid credentials" do
    post login_path, params: { username: "alice", password: "wrongpassword" }
    assert_response :unprocessable_entity
    assert_match "Invalid username or password", response.body
  end

  test "login with nonexistent user" do
    post login_path, params: { username: "nobody", password: "password123" }
    assert_response :unprocessable_entity
  end

  test "logout" do
    sign_in users(:alice)
    delete logout_path
    assert_redirected_to root_path
  end
end
