class VotesController < ApplicationController
  before_action :require_login

  def create
    @vote = current_user.votes.find_or_initialize_by(
      votable_type: params[:votable_type],
      votable_id: params[:votable_id]
    )

    if @vote.new_record?
      @vote.value = 1
      if @vote.save
        redirect_back fallback_location: root_path, notice: "Upvoted!"
      else
        redirect_back fallback_location: root_path, alert: "Could not vote."
      end
    else
      redirect_back fallback_location: root_path, alert: "You already voted on this."
    end
  end

  def destroy
    @vote = current_user.votes.find(params[:id])
    @vote.destroy
    redirect_back fallback_location: root_path, notice: "Vote removed."
  end
end
