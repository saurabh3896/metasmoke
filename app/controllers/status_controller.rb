class StatusController < ApplicationController
  protect_from_forgery :except => [:status_update]
  before_action :check_if_smokedetector, :only => [:status_update]

  def index
    @statuses = SmokeDetector.order(:created_at).all
  end

  def status_update

    commit_update = CommitStatus.where('created_at >= ?', @smoke_detector.last_ping).last
    invalidated = Feedback.unscoped.where(:is_invalidated => true).where('updated_at >= ?', @smoke_detector.last_ping)
                    .select(:post_link, :feedback_type, :user_name, :chat_user_id)

    @smoke_detector.last_ping = DateTime.now
    @smoke_detector.location = params[:location]

    @smoke_detector.save!

    respond_to do |format|
      format.json do
        render :status => commit_update.present? ? 201 : 200, :json => { :commit_update => commit_update, :invalidated => invalidated }
      end
    end
  end
end
