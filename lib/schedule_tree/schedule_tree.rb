require 'venue_node.rb'
class ScheduleTree
  attr_accessor :owner, :venues

  def initialize (owner)
    @owner = owner
    @venues = []
  end

  def addAvail (venueHash, theatreHash, date, startTime, length)
    # If venueName is in @venues, add the icetime.
    # Else, create the venue and add the icetime.
    @venues.each do |venue|

      if venue.name == venueHash[:name]
        venue.addAvail(theatreHash, date, startTime, length)
        return
      end

    end

    # venueName not found in @venues
    puts venueHash[:name]
    new_venue = VenueNode.new(venueHash[:name], venueHash[:lat], venueHash[:long], venueHash[:address])
    puts 'hello'#venueHash[:name] + '*************'
    new_venue.addAvail(theatreHash, date, startTime, length)
    @venues.push(new_venue)

  end

  def removeBeforeCutoff(params)

    @venues.each do |venue|
      venue.removeBeforeCutoff(params)
    end

  end

end