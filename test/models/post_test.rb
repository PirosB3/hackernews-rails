require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "valid link post" do
    post_record = Post.new(title: "Test", url: "https://example.com", post_type: "link", user: users(:alice))
    assert post_record.valid?
  end

  test "valid ask post" do
    post_record = Post.new(title: "Ask HN: Test?", body: "Some text", post_type: "ask", user: users(:alice))
    assert post_record.valid?
  end

  test "valid show post" do
    post_record = Post.new(title: "Show HN: Test", url: "https://example.com", post_type: "show", user: users(:alice))
    assert post_record.valid?
  end

  test "requires title" do
    post_record = Post.new(title: "", url: "https://example.com", post_type: "link", user: users(:alice))
    assert_not post_record.valid?
  end

  test "title max length is 300" do
    post_record = Post.new(title: "a" * 301, url: "https://example.com", post_type: "link", user: users(:alice))
    assert_not post_record.valid?
  end

  test "link post requires url" do
    post_record = Post.new(title: "Test", url: "", post_type: "link", user: users(:alice))
    assert_not post_record.valid?
    assert_includes post_record.errors[:url], "is required for link posts"
  end

  test "ask post requires body" do
    post_record = Post.new(title: "Ask HN: Test?", body: "", post_type: "ask", user: users(:alice))
    assert_not post_record.valid?
    assert_includes post_record.errors[:body], "can't be blank"
  end

  test "url must be valid" do
    post_record = Post.new(title: "Test", url: "not-a-url", post_type: "link", user: users(:alice))
    assert_not post_record.valid?
  end

  test "post_type must be link, ask, or show" do
    post_record = Post.new(title: "Test", url: "https://example.com", post_type: "invalid", user: users(:alice))
    assert_not post_record.valid?
  end

  test "domain extracts domain from url" do
    post_record = posts(:link_post)
    assert_equal "rubyonrails.org", post_record.domain
  end

  test "domain strips www prefix" do
    post_record = Post.new(url: "https://www.example.com/path")
    assert_equal "example.com", post_record.domain
  end

  test "domain returns nil for blank url" do
    post_record = Post.new(url: "")
    assert_nil post_record.domain
  end

  test "comments_count returns count" do
    post_record = posts(:link_post)
    assert_equal 2, post_record.comments_count
  end

  test "ranked scope returns posts" do
    posts = Post.ranked
    assert_not_empty posts
  end

  test "newest scope returns newest first" do
    posts = Post.newest
    assert posts.first.created_at >= posts.last.created_at
  end

  test "by_type scope filters by type" do
    ask_posts = Post.by_type("ask")
    ask_posts.each { |p| assert_equal "ask", p.post_type }
  end

  test "default points is 0" do
    post_record = Post.new(title: "Test", url: "https://example.com", post_type: "link", user: users(:alice))
    assert_equal 0, post_record.points
  end
end
