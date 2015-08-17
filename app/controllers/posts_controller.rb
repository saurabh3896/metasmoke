class PostsController < ApplicationController

  before_filter :authenticate_user!, :except => [:create]

  protect_from_forgery :except => [:create]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    params["post"]["reasons"].each do |r|
      reason = Reason.find_or_create_by(reason_name: r)

      @post.reasons << reason
    end

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render status: :created, :text => "OK" }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :body, :link, :result, :message_link, :message_user, :reasons)
    end
end