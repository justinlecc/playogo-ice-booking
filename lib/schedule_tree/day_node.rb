class DayNode
  attr_accessor :date, :openings

  def initialize(date)
    @date = date
    @openings = []
  end

  def addOpening (startTime, length)
    # Adds the new opening to openings
    newOpening = OpeningNode.new(startTime, length)
    @openings.push(newOpening)
  end

end
