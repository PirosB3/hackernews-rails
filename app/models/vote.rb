class Vote < ApplicationRecord
  belongs_to :votable, polymorphic: true
  belongs_to :user

  validates :value, inclusion: { in: [ 1, -1 ] }
  validates :user_id, uniqueness: { scope: [ :votable_type, :votable_id ] }

  after_create :update_votable_points
  after_destroy :update_votable_points

  private

  def update_votable_points
    votable.update_columns(points: votable.votes.sum(:value))
    votable.broadcast_points_update if votable.is_a?(Post)
  end
end
