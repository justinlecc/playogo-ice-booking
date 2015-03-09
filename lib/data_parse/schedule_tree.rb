require 'venue_node.rb'
class ScheduleTree
  attr_accessor :owner, :venues

  def initialize (owner)
    @owner = owner
    @venues = []
  end

  def addAvail (venueName, theatreHash, date, startTime, length)
    # If venueName is in @venues, add the icetime.
    # Else, create the venue and add the icetime.
    @venues.each do |venue|

      if venue.name == venueName
        venue.addAvail(theatreHash, date, startTime, length)
        return
      end

    end

    # venueName not found in @venues
    new_venue = VenueNode.new(venueName)
    new_venue.addAvail(theatreHash, date, startTime, length)
    @venues.push(new_venue)

  end


end