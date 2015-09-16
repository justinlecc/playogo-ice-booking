require 'owner_node.rb'

class ScheduleTree
  attr_accessor :owners

  def initialize ()
    @owners = []
  end

  def addOpening (ownerHash, venueHash, theatreHash, date, startTime, length)

    # If ownerName is in @owners, add the opening.
    # Else, create the owner node and add the opening.
    @owners.each do |owner|

      if owner.name == ownerHash[:name]
        owner.addOpening(venueHash, theatreHash, date, startTime, length)
        return
      end

    end

    # owner name not found in @owners
    newOwner = OwnerNode.new(ownerHash[:name])
    newOwner.addOpening(venueHash, theatreHash, date, startTime, length)
    @owners.push(newOwner)

  end

  def toVenueTree ()
    return VenueTree.new(self)
  end

end