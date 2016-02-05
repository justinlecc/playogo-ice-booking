class Booking < ActiveRecord::Base
  belongs_to :theatre

  def end_time
    return start_time + length
  end

  def getPrice
    return self.theatre.getPrice(self.date, self.start_time, self.length)
  end
end
