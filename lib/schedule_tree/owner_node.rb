require 'venue_node.rb'

class OwnerNode
  attr_accessor :name, :venues

  def initialize (name)
    @name = name
    @venues = []
  end

  def addOpening (venueHash, theatreHash, date, startTime, length)
    # If venueName is in @venues, add the opening.
    # Else, create the venue and add the opening.
    @venues.each do |venue|

      if venue.name == venueHash[:name]
        venue.addOpening(theatreHash, date, startTime, length)
        return
      end

    end

    # venueName not found in @venues
    puts venueHash[:name]
    new_venue = VenueNode.new(venueHash[:name], @name, venueHash[:lat], venueHash[:long], venueHash[:address])
    new_venue.addOpening(theatreHash, date, startTime, length)
    @venues.push(new_venue)

  end


end