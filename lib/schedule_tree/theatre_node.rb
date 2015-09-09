class TheatreNode
  attr_accessor :name, :days, :prime, :non_prime, :insurance

  def initialize(name, prime, nonPrime, insurance)
    @name = name
    @prime = prime
    @non_prime = nonPrime
    @insurance = insurance
    @days = []
  end

  def addAvail (date, startTime, length)
    # If date matches one in @days, add the icetime to it.
    # Else, create the day and add the icetime.
    @days.each do |day|

      if day.date == date
        day.addAvail(startTime, length)
        return
      end
      
    end

    # date not found in @days
    new_day = DayNode.new(date)
    new_day.addAvail(startTime, length)
    @days.push(new_day)
    @days.sort! { |a,b| a.date <=> b.date }
  end

end
