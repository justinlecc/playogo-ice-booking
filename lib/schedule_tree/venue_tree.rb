class VenueTree
  
  attr_accessor :owners

  def initialize(ownerTree)

    @venues = []

    ownerTree.owners.each do |owner|

      @venues += owner.venues

    end

  end

end