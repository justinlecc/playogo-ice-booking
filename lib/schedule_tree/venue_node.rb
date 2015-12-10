class VenueNode
  attr_accessor :name, :lat, :long, :address, :theatres, :owner_id

  def initialize (name, lat, long, address, owner_id)
    @name = name
    @lat = lat
    @long = long
    @address = address
    @theatres = []
    @owner_id = owner_id
  end

  def addAvail (theatreHash, date, startTime, length)
    # If theatreName matches on in @theatres, add the icetime to it.
    # Else, create the theatre and add the icetime.
    @theatres.each do |theatre|

      if theatre.name == theatreHash[:name]
        theatre.addAvail(date, startTime, length)
        return
      end
      
    end

    # theatreName not found in @facilities
    new_theatre = TheatreNode.new(theatreHash[:name],theatreHash[:prime],theatreHash[:non_prime],theatreHash[:insurance])
    new_theatre.addAvail(date, startTime, length)
    @theatres.push(new_theatre)

  end

  def removeBeforeCutoff(params)

    @theatres.each do |theatres|
      theatres.removeBeforeCutoff(params)
    end

  end

  def getDayWithAvails(currentDate)

    closestDate = nil
    @theatres.each do |theatre|

      returnDate = theatre.getDayWithAvails(currentDate)

      if closestDate == nil

        closestDate = returnDate

      else

        if returnDate < closestDate

          closestDate = returnDate

        end

      end

    end

    return closestDate

  end

end