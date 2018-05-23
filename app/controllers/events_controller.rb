class EventsController < ApplicationController
  def index
    # Redis.current.rpush('') if params[:events].present?
    head :ok
  end
end
