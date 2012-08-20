class TimelineEventsController < ApplicationController

  before_filter :load_timeline

  def create
    _message = params[:timeline_event][:timeline_event][:message].strip
    unless _message.blank?
      event = @timeline.reload.create_event({sender_id: @user._id, receiver_ids: [], message: _message}, UserMessage)
    end

    respond_to do |format|
      format.js {
        render :noting => true unless event
      }
      format.html {
        redirect_to timelines_path,( event ? {} : { alert: t(:message_couldnt_be_sent) })
      }
    end
  end

  private
  def load_timeline
    @timeline = Timeline.find params[:timeline_id]
    @user = current_user
    redirect_to new_session_path unless @user
  end

end