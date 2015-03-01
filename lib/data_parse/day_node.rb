class DayNode
  attr_accessor :date, :blocks

  def initialize(date)
    @date = date
    @blocks = []
  end

  def addAvail (startTime, length)
    # Adds the new avail to avails
    new_avail = IcetimeNode.new(startTime, length)
    @blocks.push(new_avail)
  end

end
