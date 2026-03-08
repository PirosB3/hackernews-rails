require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "create comment requires login" do
    assert_no_difference "Comment.count" do
      post post_comments_path(posts(:link_post)), params: { comment: { body: "Hello" } }
    end
    assert_redirected_to login_path
  end

  test "create root comment" do
    sign_in users(:alice)
    assert_difference "Comment.count", 1 do
      post post_comments_path(posts(:link_post)), params: { comment: { body: "New comment!" } }
    end
    assert_redirected_to post_path(posts(:link_post))
    assert_equal "New comment!", Comment.last.body
    assert_nil Comment.last.parent_comment_id
  end

  test "create reply comment" do
    sign_in users(:alice)
    parent = comments(:root_comment)
    assert_difference "Comment.count", 1 do
      post post_comments_path(posts(:link_post)), params: { comment: { body: "A reply!", parent_comment_id: parent.id } }
    end
    assert_equal parent.id, Comment.last.parent_comment_id
  end

  test "create comment with blank body fails" do
    sign_in users(:alice)
    assert_no_difference "Comment.count" do
      post post_comments_path(posts(:link_post)), params: { comment: { body: "" } }
    end
    assert_redirected_to post_path(posts(:link_post))
  end
end
