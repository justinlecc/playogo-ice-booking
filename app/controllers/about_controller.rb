class AboutController < ApplicationController

  # GET /about
  def index
    # Track page view
    source = params[:src] # TODO: Escape src
    v = Viewer.new
    info = v.pageView('/about', source, cookies)
    cookies[:viewer_id]    = info[:viewer_id]
    cookies[:page_view_id] = info[:page_view_id]
  end

end