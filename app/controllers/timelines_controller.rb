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
      _since = Time.now - params[:timeline][:show_timeline_since].to_i.minutes
      redirect_to timelines_path(since: _since.to_s), notice: t(:timeline_updated) + " " + _since.to_s
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
    @since = last_updated
    cookies.permanent[:timeline_last_updated] = Time.now
  end


  private
  def last_updated
    if params[:since].present?
      Time.parse params[:since]
    elsif session[:timeline_last_updated] || cookies[:timeline_last_updated]
      session[:timeline_last_updated] || cookies[:timeline_last_updated]
    else
      Time.now-(Settings.timeline.default_duration || 60).minutes
    end
  end

  def load_timelines
    @timelines = current_user.timelines
    Rails.logger.info "*"*40 + "\n" + last_updated.inspect
    @events = current_user.events( last_updated )
  end

  def set_timeline_duration
    if params[:timeline][:show_timeline_since].present?
      session[:show_timeline_since] = params[:timeline][:show_timeline_since].to_i
    end
  end

end