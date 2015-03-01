class Opening < ActiveRecord::Base
  belongs_to :theatre

  def end_time
    return length + start_time
  end
end
