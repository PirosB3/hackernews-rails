require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "valid comment" do
    comment = Comment.new(body: "Great post!", user: users(:alice), post: posts(:link_post))
    assert comment.valid?
  end

  test "requires body" do
    comment = Comment.new(body: "", user: users(:alice), post: posts(:link_post))
    assert_not comment.valid?
  end

  test "can have parent_comment" do
    parent = comments(:root_comment)
    reply = Comment.new(body: "Reply!", user: users(:alice), post: posts(:link_post), parent_comment: parent)
    assert reply.valid?
  end

  test "root_comments scope excludes replies" do
    root = Comment.root_comments
    root.each { |c| assert_nil c.parent_comment_id }
  end

  test "replies association" do
    parent = comments(:root_comment)
    assert_includes parent.replies, comments(:reply_comment)
  end

  test "destroying parent destroys replies" do
    parent = comments(:root_comment)
    reply_id = comments(:reply_comment).id
    parent.destroy
    assert_nil Comment.find_by(id: reply_id)
  end

  test "default points is 0" do
    comment = Comment.new(body: "Test", user: users(:alice), post: posts(:link_post))
    assert_equal 0, comment.points
  end
end
