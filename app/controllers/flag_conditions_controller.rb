class FlagConditionsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin, :only => [:full_list]
  before_action :set_condition, :only => [:edit, :update, :destroy]
  before_action :verify_authorized, :only => [:edit, :update, :destroy]
  before_action :check_registration_status, :only => [:new]
  before_action :set_preview_data, :only => [:new, :edit, :preview]

  def index
    @conditions = current_user.flag_conditions
  end

  def full_list
    @conditions = FlagCondition.all
  end

  def new
    @condition = FlagCondition.new
  end

  def create
    @condition = FlagCondition.new condition_params
    @condition.user = current_user
    @condition.sites = Site.where(:id => params[:sites])

    if @condition.save
      flash[:success] = "Created a new flagging condition."
      redirect_to url_for(:controller => :flag_conditions, :action => :index)
    else
      render :new
    end
  end

  def edit
  end

  def update
    condition_params = condition_params().merge({ :sites => Site.where(:id => params[:sites]) })

    if @condition.update(condition_params)
      flash[:success] = "Updated your flagging condition."
      redirect_to url_for(:controller => :flag_conditions, :action => :index)
    else
      render :edit, :status => 422
    end
  end

  def destroy
    if @condition.destroy
      flash[:success] = "Removed your flagging condition."
    else
      flash[:danger] = "Failed to remove the condition - contact a developer to find out why."
    end
    redirect_to url_for(:controller => :flag_conditions, :action => :index)
  end

  def preview
    @condition = FlagCondition.new(condition_params)
    set_preview_data

    respond_to do |format|
      format.js
    end
  end

  private
  def set_condition
    @condition = FlagCondition.find params[:id]
  end

  def condition_params
    params.require(:flag_condition).permit(:min_weight, :max_poster_rep, :min_reason_count)
  end

  def verify_authorized
    current_user.has_role?(:admin) || @condition.user == current_user
  end

  def check_registration_status
    raise ActionController::RoutingError.new('Not Found') if FlagSetting['registration_enabled'] == '0'
  end

  def set_preview_data
    if @condition
      posts = Post.joins(:reasons).group('posts.id').where('posts.user_reputation <= ?', @condition.max_poster_rep).having('count(reasons.id) >= ?', @condition.min_reason_count).having('sum(reasons.weight) >= ?', @condition.min_weight)

      post_feedback_results = posts.pluck(:is_tp)

      @false_positive_count = post_feedback_results.count(false)
      @true_positive_count = post_feedback_results.count(true)

      @posts = posts.includes(:feedbacks => [:user]).order('posts.id DESC').paginate(:page => params[:page], :per_page => 100)
      @sites = Site.where(:id => @posts.map(&:site_id)).to_a
    end
  end
end
