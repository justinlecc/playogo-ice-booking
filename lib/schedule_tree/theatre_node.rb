class TheatreNode
  attr_accessor :name, :days, :prime, :non_prime, :insurance

  def initialize(name, prime, nonPrime, insurance)
    @name = name
    @prime = prime
    @non_prime = nonPrime
    @insurance = insurance
    @days = []
  end

  def addOpening (date, startTime, length)
    # If date matches one in @days, add the opening to it.
    # Else, create the day and add the opening.
    @days.each do |day|

      if day.date == date
        day.addOpening(startTime, length)
        return
      end
      
    end

    # date not found in @days
    new_day = DayNode.new(date)
    new_day.addOpening(startTime, length)
    @days.push(new_day)
    @days.sort! { |a,b| a.date <=> b.date }
  end

end
