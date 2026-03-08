require "test_helper"

class VotesControllerTest < ActionDispatch::IntegrationTest
  test "voting requires login" do
    post votes_path, params: { votable_type: "Post", votable_id: posts(:link_post).id }
    assert_redirected_to login_path
  end

  test "upvote a post" do
    sign_in users(:bob)
    assert_difference "Vote.count", 1 do
      post votes_path, params: { votable_type: "Post", votable_id: posts(:link_post).id }
    end
  end

  test "upvote updates post points" do
    sign_in users(:bob)
    post votes_path, params: { votable_type: "Post", votable_id: posts(:link_post).id }
    posts(:link_post).reload
    assert_equal 1, posts(:link_post).points
  end

  test "cannot double vote" do
    sign_in users(:alice)
    post votes_path, params: { votable_type: "Post", votable_id: posts(:link_post).id }
    assert_no_difference "Vote.count" do
      post votes_path, params: { votable_type: "Post", votable_id: posts(:link_post).id }
    end
  end

  test "upvote a comment" do
    sign_in users(:alice)
    assert_difference "Vote.count", 1 do
      post votes_path, params: { votable_type: "Comment", votable_id: comments(:root_comment).id }
    end
  end

  test "unvote removes vote" do
    sign_in users(:alice)
    post votes_path, params: { votable_type: "Post", votable_id: posts(:ask_post).id }
    vote = Vote.last
    assert_difference "Vote.count", -1 do
      delete vote_path(vote)
    end
  end

  test "unvote updates points" do
    sign_in users(:alice)
    post votes_path, params: { votable_type: "Post", votable_id: posts(:ask_post).id }
    posts(:ask_post).reload
    assert_equal 1, posts(:ask_post).points
    vote = Vote.last
    delete vote_path(vote)
    posts(:ask_post).reload
    assert_equal 0, posts(:ask_post).points
  end
end
