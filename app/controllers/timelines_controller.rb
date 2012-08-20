class TimelinesController < ApplicationController

  before_filter  :load_timelines

  def index
  end

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

  def update_timeline
  end


private
  def load_timelines
    @timelines = current_user.timeline_subscriptions.map(&:timeline)
    @events = current_user.events
  end

end