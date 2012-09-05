# -*- encoding : utf-8 -*-"
#
# @author Andi Altendorfer <andreas@altendorfer.at>
#
module Api
  module V1
    class TimelinesController < ApplicationController
      respond_to :json

      before_filter :check_api_token

      # GET /api/v1/timelines[.json]
      def index
        respond_with Timeline.only([:_id, :name]).map { |timeline|
          if _last = timeline.timeline_events.last
            _latest = last
          else
            _latest = nil
          end
          { id: timeline.id, name: timeline.name, last_event: _latest }
        }
      end

      # GET /api/v1/timelines/:id[.json]
      def show
        respond_with Timeline.find(params[:id])
      end

      # GET /api/v1/timelines/events[.json]
      def events
        timeline = Timeline.find(params[:id])
        respond_with timeline.timeline_events
      end

      # POST /api/v1/timelines/:id/create_event   optional: ?event='{\"message\":\"Hello\"}'
      def create_event
        timeline = Timeline.find(params[:id])
        begin
          if( _event = timeline.timeline_events.create( extract_event ) )
            render json: _event
          else
            render json: "Can't create event. #{params[:event].inspect} in Timeline #{timeline.inspect}", status: 500
          end
        rescue => e
          Rails.logger.warn("Can't create event. Error: #{e.inspect} in #{__FILE__}:#{__LINE__} with params #{params.inspect}")
        end
      end

      private

      # Parse params[:event] as JSON-string unless it's an hash
      def extract_event
        if params[:event].class == ActiveSupport::HashWithIndifferentAccess
          params[:event]
        else
          _rc = {}
          JSON.parse(params[:event].to_s).each do |key, value|
            _rc[key.to_sym] = value
          end
          _rc
        end
      end

      def check_api_token
        unless params[:token].present? && Settings.api.tokens.include?(params[:token])
          render json: {error: "API-TOKEN NOT ACCEPTED"}, status: "406 - Not Accaptable Request"
        end
      end
    end
  end
end