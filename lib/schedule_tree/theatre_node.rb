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

  def removeBeforeCutoff(params)

    @days.delete_if do |day|
      if day.date < params[:date]
        true
      elsif day.date == params[:date]
        day.removeBeforeCutoff(params[:time]);
        false
      else
        false
      end
    end

  end

  def getDayWithAvails(currentDate)

    closestDate = nil

    @days.each do |day|

      if day.hasAvail

        if closestDate == nil

          closestDate = day.date

        else

          if day.date >= currentDate

            if day.date < closestDate

              closestDate = day.date

            end

          end

        end

      end

    end

    return closestDate

  end

end
