class UseTrackingController < ApplicationController

  def page_action
    p = PageView.find(cookies[:page_view_id])
    a = PageAction.create!({
      :page_view => p,
      :action    => params[:action_type]
    })

    render nothing: true
  end
end
