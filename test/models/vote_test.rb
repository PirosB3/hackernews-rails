require "test_helper"

class VoteTest < ActiveSupport::TestCase
  test "valid upvote" do
    vote = Vote.new(value: 1, user: users(:alice), votable: posts(:link_post))
    assert vote.valid?
  end

  test "valid downvote" do
    vote = Vote.new(value: -1, user: users(:alice), votable: posts(:link_post))
    assert vote.valid?
  end

  test "value must be 1 or -1" do
    vote = Vote.new(value: 2, user: users(:alice), votable: posts(:link_post))
    assert_not vote.valid?
  end

  test "user can only vote once per votable" do
    Vote.create!(value: 1, user: users(:alice), votable: posts(:link_post))
    duplicate = Vote.new(value: 1, user: users(:alice), votable: posts(:link_post))
    assert_not duplicate.valid?
  end

  test "different users can vote on same votable" do
    Vote.create!(value: 1, user: users(:alice), votable: posts(:link_post))
    vote = Vote.new(value: 1, user: users(:bob), votable: posts(:link_post))
    assert vote.valid?
  end

  test "after_create updates votable points" do
    post_record = posts(:ask_post)
    Vote.create!(value: 1, user: users(:alice), votable: post_record)
    post_record.reload
    assert_equal 1, post_record.points
  end

  test "after_destroy updates votable points" do
    post_record = posts(:ask_post)
    vote = Vote.create!(value: 1, user: users(:alice), votable: post_record)
    post_record.reload
    assert_equal 1, post_record.points
    vote.destroy
    post_record.reload
    assert_equal 0, post_record.points
  end
end
