# ******************************************************************
#
# Readers are meant to read the the raw data from their respective
# owners and transform them into ScheduleTree objects.
#
# ******************************************************************


class WoolwichScheduleReader

  def initialize()

    # Hard coded attributes of Woolwich Venues
    @owner_name    = "Woolwich"
    @manager_name  = "Gloria"
    @manager_email = "playogosports@gmail.com"

  end

  # Returns a hash of hard coded information about the Woolwich venue
  def getVenueLocationHash(venue) 
    lat = nil
    long = nil
    address = nil
    return {:name => venue, :lat => lat, :long => long, :address => address}
  end

  # Returns a hash of hard coded information about the Woolwich theatre
  def getTheatreHash(theatre)
    return {:prime => 20000, :non_prime => 15000, :insurance => 400, :name => theatre}
  end
  
  # Reads in raw schedule format and converts it to a ScheduleTree object
  def rawToScheduleTree(rawSchedule)

    # Struture to hold openings
    scheduleTree = ScheduleTree.new()

    # File name of doc to be parsed should be param 
    doc_path = Rails.root.join('lib', 'schedule_readers', 'woolwich', 'schedule.json')

    puts File.read(doc_path)

    return scheduleTree
    
  end


  # Reads Woolwich's raw schedule data and updates the database
  def scheduleToDatabase()
    scheduleFile = 'woolwich_data.json'

    # 1. Get a ScheduleTree from Woolwich's raw data

    # 2. Create new scheduleUpdater and pass it the tree

  end

end
