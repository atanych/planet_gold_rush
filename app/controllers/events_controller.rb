class EventsController < ApplicationController
  def index
    Redis.current.rpush(Settings.event_list_key, params[:event]) if params[:event].present?
    head :ok
  end
end
