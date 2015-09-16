class VenueNode
  attr_accessor :name, :lat, :long, :address, :theatres

  def initialize (name, owner, lat, long, address)
    @name     = name
    @owner    = owner
    @lat      = lat
    @long     = long
    @address  = address
    @theatres = []
  end

  def addOpening (theatreHash, date, startTime, length)
    # If theatreName matches on in @theatres, add the opening to it.
    # Else, create the theatre and add the opening.
    @theatres.each do |theatre|

      if theatre.name == theatreHash[:name]
        theatre.addOpening(date, startTime, length)
        return
      end
      
    end

    # theatreName not found in @facilities
    new_theatre = TheatreNode.new(theatreHash[:name],theatreHash[:prime],theatreHash[:non_prime],theatreHash[:insurance])
    new_theatre.addOpening(date, startTime, length)
    @theatres.push(new_theatre)

  end

end