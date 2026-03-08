class Post < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy

  after_create_commit :broadcast_new_post

  validates :title, presence: true, length: { maximum: 300 }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :post_type, inclusion: { in: %w[link ask show] }
  validates :body, presence: true, if: -> { post_type == "ask" }
  validate :url_required_for_link

  scope :ranked, -> {
    if connection.adapter_name == "PostgreSQL"
      order(Arel.sql("posts.points / POWER((EXTRACT(EPOCH FROM (NOW() - posts.created_at)) / 3600.0 + 2), 1.8) DESC"))
    else
      order(Arel.sql("posts.points / POWER((CAST((julianday('now') - julianday(posts.created_at)) * 24 AS REAL) + 2), 1.8) DESC"))
    end
  }
  scope :newest, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(post_type: type) }

  def domain
    return nil if url.blank?
    URI.parse(url).host&.sub(/\Awww\./, "")
  rescue URI::InvalidURIError
    nil
  end

  def comments_count
    comments.count
  end

  def broadcast_points_update
    points_html = "<span id=\"#{ActionView::RecordIdentifier.dom_id(self, :points)}\">#{points} point#{'s' if points != 1}</span>"

    Turbo::StreamsChannel.broadcast_replace_to "posts",
      target: ActionView::RecordIdentifier.dom_id(self, :points),
      html: points_html

    Turbo::StreamsChannel.broadcast_replace_to self,
      target: ActionView::RecordIdentifier.dom_id(self, :points),
      html: points_html
  end

  private

  def broadcast_new_post
    broadcast_prepend_to "posts", target: "posts", partial: "posts/post", locals: { post: self }
  end

  def url_required_for_link
    if post_type == "link" && url.blank?
      errors.add(:url, "is required for link posts")
    end
  end
end
