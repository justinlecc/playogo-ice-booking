class Booking < ActiveRecord::Base
  belongs_to :theatre

  def end_time
    return start_time + length
  end
end
