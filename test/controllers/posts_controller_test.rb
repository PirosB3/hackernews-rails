require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "index shows posts" do
    get root_path
    assert_response :success
    assert_select "a", text: posts(:link_post).title
  end

  test "newest shows posts sorted by newest" do
    get newest_path
    assert_response :success
  end

  test "ask shows ask posts only" do
    get ask_path
    assert_response :success
  end

  test "show_hn shows show posts only" do
    get show_hn_path
    assert_response :success
  end

  test "show displays post" do
    get post_path(posts(:link_post))
    assert_response :success
    assert_select "a", text: posts(:link_post).title
  end

  test "show displays comments" do
    get post_path(posts(:link_post))
    assert_response :success
    assert_match comments(:root_comment).body, response.body
  end

  test "new requires login" do
    get new_post_path
    assert_redirected_to login_path
  end

  test "new renders form when logged in" do
    sign_in users(:alice)
    get new_post_path
    assert_response :success
  end

  test "create post when logged in" do
    sign_in users(:alice)
    assert_difference "Post.count", 1 do
      post posts_path, params: { post: { title: "New Post", url: "https://example.com", post_type: "link" } }
    end
    assert_redirected_to post_path(Post.last)
  end

  test "create post fails with invalid data" do
    sign_in users(:alice)
    assert_no_difference "Post.count" do
      post posts_path, params: { post: { title: "", url: "", post_type: "link" } }
    end
    assert_response :unprocessable_entity
  end

  test "edit requires login" do
    get edit_post_path(posts(:link_post))
    assert_redirected_to login_path
  end

  test "edit requires ownership" do
    sign_in users(:bob)
    get edit_post_path(posts(:link_post))
    assert_redirected_to post_path(posts(:link_post))
  end

  test "edit renders form for owner" do
    sign_in users(:alice)
    get edit_post_path(posts(:link_post))
    assert_response :success
  end

  test "update post" do
    sign_in users(:alice)
    patch post_path(posts(:link_post)), params: { post: { title: "Updated Title" } }
    assert_redirected_to post_path(posts(:link_post))
    posts(:link_post).reload
    assert_equal "Updated Title", posts(:link_post).title
  end

  test "destroy post" do
    sign_in users(:alice)
    assert_difference "Post.count", -1 do
      delete post_path(posts(:link_post))
    end
    assert_redirected_to root_path
  end

  test "destroy requires ownership" do
    sign_in users(:bob)
    assert_no_difference "Post.count" do
      delete post_path(posts(:link_post))
    end
  end

  test "pagination with page param" do
    get root_path(page: 2)
    assert_response :success
  end
end
