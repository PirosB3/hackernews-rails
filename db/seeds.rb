puts "Seeding database..."

alice = User.create!(username: "alice", email: "alice@example.com", password: "password123", password_confirmation: "password123")
bob = User.create!(username: "bob", email: "bob@example.com", password: "password123", password_confirmation: "password123")
charlie = User.create!(username: "charlie", email: "charlie@example.com", password: "password123", password_confirmation: "password123")

posts_data = [
  { title: "Ruby on Rails 8.0 Released", url: "https://rubyonrails.org/2024/11/7/rails-8-no-paas-required", post_type: "link", user: alice },
  { title: "Show HN: I built a Hacker News clone in Rails", url: "https://github.com/example/hackernews-rails", post_type: "show", user: bob },
  { title: "Ask HN: What are you working on?", body: "Curious what side projects everyone is hacking on this weekend.", post_type: "ask", user: charlie },
  { title: "The Pragmatic Programmer at 25", url: "https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/", post_type: "link", user: alice },
  { title: "Why SQLite is Perfect for Most Applications", url: "https://www.sqlite.org/whentouse.html", post_type: "link", user: bob },
  { title: "Show HN: A terminal-based music player", url: "https://github.com/example/terminal-music", post_type: "show", user: charlie },
  { title: "Ask HN: Best resources for learning systems programming?", body: "Looking to learn more about operating systems and low-level programming.", post_type: "ask", user: alice },
  { title: "Tailwind CSS v4.0 is Here", url: "https://tailwindcss.com/blog/tailwindcss-v4", post_type: "link", user: bob },
  { title: "How We Scaled Our Rails App to 10M Users", url: "https://example.com/scaling-rails", post_type: "link", user: charlie },
  { title: "The Future of WebAssembly", url: "https://example.com/wasm-future", post_type: "link", user: alice },
]

posts = posts_data.map { |data| Post.create!(data) }

posts.each_with_index do |post, i|
  Vote.create!(votable: post, user: [alice, bob, charlie].sample, value: 1) rescue nil
  Vote.create!(votable: post, user: [alice, bob, charlie].reject { |u| u == post.user }.sample, value: 1) rescue nil
end

comments_data = [
  { body: "This is a game changer! The no-PaaS approach is exactly what we needed.", user: bob, post: posts[0] },
  { body: "Agreed, Kamal + Solid Queue is a killer combo.", user: charlie, post: posts[0] },
  { body: "Looks great! What stack did you use for the frontend?", user: alice, post: posts[1] },
  { body: "I'm working on a CLI tool for managing dotfiles. It's been fun learning about symlinks.", user: alice, post: posts[2] },
  { body: "Building a chess engine in Rust! Just got alpha-beta pruning working.", user: bob, post: posts[2] },
  { body: "SQLite really is underappreciated. We use it in production and it handles our load fine.", user: charlie, post: posts[4] },
  { body: "For systems programming, I highly recommend CS:APP (Computer Systems: A Programmer's Perspective).", user: bob, post: posts[6] },
  { body: "Also check out Nand2Tetris - it's an incredible course.", user: charlie, post: posts[6] },
]

comments = comments_data.map { |data| Comment.create!(data) }

Comment.create!(body: "Thanks for the recommendations!", user: alice, post: posts[6], parent_comment: comments[6])
Comment.create!(body: "The Hotwire integration improvements are really nice too.", user: alice, post: posts[0], parent_comment: comments[0])

puts "Seeded #{User.count} users, #{Post.count} posts, #{Comment.count} comments, #{Vote.count} votes."
