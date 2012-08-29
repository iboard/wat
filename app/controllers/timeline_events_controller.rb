class TimelineEventsController < ApplicationController

  before_filter :load_timeline

  def create
    _event =   params[:timeline_event][:timeline_event]
    _message = _event[:message].strip
    _timelines = params[:timelines_to].present? ? params[:timelines_to].map(&:first) : nil
    _event[:timelines_to] = _timelines if _timelines
    _event[:sender_id] = @user._id

    unless _message.blank?
      event = @user.timeline.create_event( _event, UserMessage)
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