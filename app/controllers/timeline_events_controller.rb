class TimelineEventsController < ApplicationController

  before_filter :load_timeline

  def create
    _message = params[:timeline_event][:timeline_event][:message]
    if (_message||'').strip.blank?
      render :noting => true
    else
      @timeline.reload.create_event({sender_id: @user._id, receiver_ids: [], message: _message}, UserMessage)
    end
  end

  private
  def load_timeline
    @timeline = Timeline.find params[:timeline_id]
    @user = current_user
    redirect_to new_session_path unless @user
  end

end