class OpeningNode
  attr_accessor :start, :length

  def initialize(startTime, length)
    @start = startTime
    @length = length
  end

  def end
    return @start + @length
  end

end

