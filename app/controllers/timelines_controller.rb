class TimelinesController < ApplicationController


  before_filter  :load_timelines
  before_filter  :set_timeline_duration, only: [:update]

  # GET /timelines
  # Sets no_timeline to prevent timeline-view (in corner) on this page
  def index
    @no_timeline = true
  end

  # User updates "personal timeline" in timelines_path
  def update
    user = User.find(params[:user_id])
    redirect_to root_path, alert: t(:access_denied) unless user == current_user || current_user.can_execute?('Admin')

    timeline = user.timeline
    if (timeline && timeline.update_attributes(params[:timeline])) || user.create_timeline( params[:timeline])
      redirect_to timelines_path, notice: t(:timeline_updated)
    else
      redirect_to timelines_path, alert: (t(:error_updating_timeline) + ":<br/>" + timeline.errors.full_messages.join("<br/>")).html_safe
    end
  end

  # user clicks on show/hide timeline
  def toggle
    @timeline_display = session[:timeline][:display] == :hidden ? :show : :hidden
    session[:timeline][:display] = @timeline_display
    respond_to do |format|
      format.js {}
      format.html {
        redirect_to timelines_path
      }
    end
  end

  # Ajax request called every 5 seconds from timeline.coffee
  def update_timeline
  end


private
  def load_timelines
    @timelines = current_user.timelines
    @events = current_user.events( (session[:show_timeline_since] || 60).minutes )
  end

  def set_timeline_duration
    if params[:timeline][:show_timeline_since].present?
      session[:show_timeline_since] = params[:timeline][:show_timeline_since].to_i
    end
  end

end