
class WoolwichScheduleReader
  # def getTheatreHash(theatre)
  #   return {:prime => 20000, :non_prime => 15000, :insurance => 500, :name => theatre}
  # end

  # def getVenueLocationHash(venue) 
  #   lat = nil
  #   long = nil
  #   address = nil
  #   return {:name => venue, :lat => lat, :long => long, :address => address}
  # end

  def scheduleToDatabase()
    scheduleFile = 'woolwich_data.json'
    treeToDatabase(scheduleToTree(scheduleFile))
  end

  def treeToDatabase (tree)
    
  end
  
  def scheduleToTree(schedule)

    return schedule
    
  end


end
