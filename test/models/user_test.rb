require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(username: "testuser", email: "test@example.com", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "requires username" do
    user = User.new(username: "", email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "requires unique username case insensitive" do
    user = User.new(username: "Alice", email: "new@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "username length must be 2-20" do
    user = User.new(username: "a", email: "test@example.com", password: "password123")
    assert_not user.valid?

    user.username = "a" * 21
    assert_not user.valid?
  end

  test "username only allows alphanumeric and underscores" do
    user = User.new(username: "bad user!", email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:username], "only allows letters, numbers, and underscores"
  end

  test "requires email" do
    user = User.new(username: "testuser", email: "", password: "password123")
    assert_not user.valid?
  end

  test "requires valid email format" do
    user = User.new(username: "testuser", email: "notanemail", password: "password123")
    assert_not user.valid?
  end

  test "requires unique email case insensitive" do
    user = User.new(username: "newuser", email: "Alice@example.com", password: "password123")
    assert_not user.valid?
  end

  test "voted_on? returns true when user has voted" do
    user = users(:alice)
    post_record = posts(:link_post)
    user.votes.create!(votable: post_record, value: 1)
    assert user.voted_on?(post_record)
  end

  test "voted_on? returns false when user has not voted" do
    user = users(:alice)
    post_record = posts(:ask_post)
    assert_not user.voted_on?(post_record)
  end

  test "vote_for returns the vote" do
    user = users(:alice)
    post_record = posts(:link_post)
    vote = user.votes.create!(votable: post_record, value: 1)
    assert_equal vote, user.vote_for(post_record)
  end

  test "has_secure_password authenticates" do
    user = users(:alice)
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong")
  end
end
