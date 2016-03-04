class Viewer < ActiveRecord::Base
  has_many :page_views
  def pageView (page, source, cookies)

    if (cookies[:viewer_id])
      begin
        pageViewer = Viewer.find(cookies[:viewer_id])
      rescue
        pageViewer = Viewer.create!()
      end
    else
      pageViewer = Viewer.create!()
    end

    pageView = PageView.create!({:page   => page,
                                 :source => source,
                                 :viewer => pageViewer})

    return {:viewer_id     => pageViewer.id,
            :page_view_id  => pageView.id}

  end
end
