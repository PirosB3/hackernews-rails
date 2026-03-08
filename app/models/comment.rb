class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :parent_comment, class_name: "Comment", optional: true

  has_many :replies, class_name: "Comment", foreign_key: :parent_comment_id, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy

  validates :body, presence: true

  scope :root_comments, -> { where(parent_comment_id: nil) }
  scope :ranked, -> { order(points: :desc, created_at: :asc) }

  after_create_commit :broadcast_new_comment

  private

  def broadcast_new_comment
    target = if parent_comment_id?
      ActionView::RecordIdentifier.dom_id(parent_comment, :replies)
    else
      ActionView::RecordIdentifier.dom_id(post, :comments)
    end

    broadcast_append_to post,
      target: target,
      partial: "comments/comment",
      locals: { comment: self, depth: 0 }
  end
end
