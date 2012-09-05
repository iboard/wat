class TimelinesController < ApplicationController


  before_filter  :initialize_timeline_session
  before_filter  :load_timelines

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
    if (timeline && update_or_create_timeline(timeline, user))
      redirect_to timelines_path(since: @since), notice: t(:timeline_updated)
    else
      redirect_to timelines_path(since: fetch_events_since), alert: (t(:error_updating_timeline) + ":<br/>" + timeline.errors.full_messages.join("<br/>")).html_safe
    end
  end

  # user clicks on show/hide timeline
  def toggle
    toggle_timeline_display
    respond_to do |format|
      format.js {}
      format.html {
        redirect_to timelines_path
      }
    end
  end

  # Ajax request called every 5 seconds from timeline.coffee
  def update_timeline
    @since = last_updated
  end


  private

  def toggle_timeline_display
    session[:timeline][:display] = @timeline_session[:display] == :show ? :hidden : :show
    cookies.permanent[:timeline] = session[:timeline]
  end

  def load_timelines
    @timelines = current_user.timelines
    @events = current_user.events( last_updated )
  end

  def last_updated
    if params[:since].present?
      Time.parse params[:since]
    elsif
      Time.now - @timeline_session[:show_timeline_since].to_i.minutes
    end
  end

  def update_or_create_timeline(timeline, user)
    timeline.update_attributes(params[:timeline])
    session[:timeline][:show_timeline_since] = params[:timeline][:show_timeline_since]
    @timeline_session[:show_timeline_since] = params[:timeline][:show_timeline_since]
    @since = Time.now - params[:timeline][:show_timeline_since].to_i.minutes
  end


end