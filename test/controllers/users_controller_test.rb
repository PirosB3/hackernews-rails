require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "signup page renders" do
    get signup_path
    assert_response :success
  end

  test "signup with valid data" do
    assert_difference "User.count", 1 do
      post signup_path, params: { user: { username: "newuser", email: "new@example.com", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to root_path
  end

  test "signup with invalid data" do
    assert_no_difference "User.count" do
      post signup_path, params: { user: { username: "", email: "", password: "password123", password_confirmation: "password123" } }
    end
    assert_response :unprocessable_entity
  end

  test "signup with mismatched passwords" do
    assert_no_difference "User.count" do
      post signup_path, params: { user: { username: "newuser", email: "new@example.com", password: "password123", password_confirmation: "different" } }
    end
    assert_response :unprocessable_entity
  end

  test "user profile page" do
    get user_path(username: "alice")
    assert_response :success
    assert_match "alice", response.body
  end

  test "user profile shows posts" do
    get user_path(username: "alice")
    assert_match posts(:link_post).title, response.body
  end

  test "user profile shows comments" do
    get user_path(username: "alice")
    assert_match comments(:reply_comment).body, response.body
  end

  test "nonexistent user returns 404" do
    get user_path(username: "nonexistent")
    assert_response :not_found
  end
end
