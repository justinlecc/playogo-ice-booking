class VenueNode
  attr_accessor :name, :theatres

  def initialize (name)
    @name = name
    @theatres = []
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

end