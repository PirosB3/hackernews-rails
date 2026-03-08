class PostsController < ApplicationController
  before_action :require_login, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  PER_PAGE = 30

  def index
    @posts = Post.order(points: :desc, created_at: :desc)
                 .includes(:user)
                 .offset(page_offset)
                 .limit(PER_PAGE)
    @page = current_page
  end

  def newest
    @posts = Post.order(created_at: :desc)
                 .includes(:user)
                 .offset(page_offset)
                 .limit(PER_PAGE)
    @page = current_page
    render :index
  end

  def ask
    @posts = Post.where(post_type: "ask")
                 .order(created_at: :desc)
                 .includes(:user)
                 .offset(page_offset)
                 .limit(PER_PAGE)
    @page = current_page
    render :index
  end

  def show_hn
    @posts = Post.where(post_type: "show")
                 .order(created_at: :desc)
                 .includes(:user)
                 .offset(page_offset)
                 .limit(PER_PAGE)
    @page = current_page
    render :index
  end

  def show
    @comments = @post.comments.where(parent_comment_id: nil)
                     .includes(:user, :replies)
                     .order(points: :desc, created_at: :asc)
    @comment = Comment.new
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to @post, notice: "Post created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to root_path, notice: "Post deleted."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_owner!
    unless @post.user == current_user
      redirect_to @post, alert: "You are not authorized to do that."
    end
  end

  def post_params
    params.require(:post).permit(:title, :url, :body, :post_type)
  end

  def current_page
    (params[:page] || 1).to_i
  end

  def page_offset
    (current_page - 1) * PER_PAGE
  end
end
