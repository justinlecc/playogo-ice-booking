
class KitchenerDataParse  
  def getTheatreHash(theatre)
    return {:prime => 20000, :non_prime => 15000, :insurance => 500, :name => theatre}
  end

  def getVenueLocationHash(venue) 
    lat = nil
    long = nil
    address = nil
    if (venue == "Activa")
      lat = 43.422195
      long = -80.471301
      address = "135 Lennox Lewis Way, Kitchener, ON N2C 2V1"
    elsif (venue == "Don McLaren Arena")
      lat = 43.455620
      long = -80.510346
      address = "61 Green St, Kitchener, ON N2G 4K9"
    elsif (venue == "Grand River Arena")
      lat = 43.456834
      long = -80.435159
      address = "555 Heritage Dr Kitchener, ON N2B 3T9"
    elsif (venue == "KMAC")
      lat = 43.447354
      long = -80.466996
      address = "400 East Ave, Kitchener, ON N2H 1Z6"
    elsif (venue ==  "Lions Arena")
      lat = 43.413069
      long = -80.483683
      address = "20 Rittenhouse Rd. Kitchener, ON N2E 2M9"
    elsif (venue ==  "Sportsworld")
      lat = 43.411308
      long = -80.396426
      address = "35 Sportsworld Crossing Road, Kitchener, ON N2P 0A5"
    else
      throw "ERROR: Invalid venue name in getVenueLocationHash()"
    end
    return {:name => venue, :lat => lat, :long => long, :address => address}
  end

  def load
    xmlFile = 'kitchener_data.xml'
    treeToDatabase(xmlToTree(xmlFile))
  end

  def treeToDatabase (availTree)
    clear_data = 1
    # Delete current openings
    Opening.delete_all
    if (clear_data)
      Booking.delete_all
      Price.delete_all
      Theatre.delete_all
      Venue.delete_all
      Owner.delete_all
    end

    @kitchener = nil
    if (clear_data)
      @kitchener = Owner.create!({:name => "Kitchener",
                                  :manager_name => "Ashley Kropf",
                                  :manager_email => "playogosports@gmail.com"});
    else
      @kitchener = Owner.find({:name => "Kitchener"}).first;
    end

    # Create new avails
    availTree.venues.each do |venue|
      if (clear_data)
        locationHash = getVenueLocationHash(venue.name) 
        @cur_venue = Venue.create!({:name => venue.name, 
                                    :owner => @kitchener,
                                    :lat => venue.lat,
                                    :long => venue.long, #locationHash[:long],
                                    :address => venue.address })#locationHash[:address]});
      else
        @cur_venue = Venue.find({:name => venue.name}).first;
      end
      venue.theatres.each do |theatre|
        if (clear_data) 
          @cur_theatre = Theatre.create!({:name => theatre.name, :venue => @cur_venue})
          Price.create!({:prime => 20000, :non_prime => 15000, :insurance => 533, :theatre => @cur_theatre})
        else
          @cur_theatre = Theatre.find({:name => theatre.name, :venue => @cur_venue})
        end
        theatre.days.each do |day|
          day.blocks.each do |block|
            Opening.create!({:start_time => block.start, 
                             :length => block.length, 
                             :date => day.date,
                             :theatre => @cur_theatre})
          end
        end
      end
    end
  end
  
  def xmlToTree(xmlFile)
    # Struture to hold availabilities
    availTree = ScheduleTree.new("Kitchener")

    # File name of doc to be parsed should be param 
    doc_path = Rails.root.join('lib', 'data_parse', xmlFile)
    # Get xml into Nokogiri format
    doc = Nokogiri::XML(File.read(doc_path))

    # Iterate through each page
    pages = doc.xpath("/pdf2xml/page")
    pages.each do |page|

      # Get the table cells of the page
      cells = page.xpath("./text").to_a

      # Drop the unneccessary header cells of the page.
      if page.xpath("./@number")[0].value == "1"
        cells = cells.drop(9)
      else
        cells = cells.drop(1)
      end

      # Loop through cells.
      # Each iteration will use the values from 8 cells (one row).
      i = 0
      while (i+7 < cells.length)

        # Assert that column 0 value is "No"
        if (cells[i].inner_text != "No")
          raise "ERROR: 'No' not found"
        end

        # Get row data
        venue = cells[i + 1].inner_text
        theatre = cells[i + 2].inner_text
        # don't need day of the week (cells[i + 3])
        start_date = cells[i + 4].inner_text
        start_time = cells[i + 5].inner_text
        end_date = cells[i + 6].inner_text
        end_time = cells[i + 7].inner_text

        if (theatre != "Floor" && venue != "Queensmount Arena")

          # Create datetimes
          start_datetime = DateTime.strptime(start_date + " " + start_time, "%d %b %Y %H:%M %p")
          end_datetime =  DateTime.strptime(end_date + " " + end_time, "%d %b %Y %H:%M %p")

          # Assert that start_datetime is before end_datetime
          if (start_datetime >= end_datetime)
            raise "ERROR: start_datetime is later than end_datetime"
          end

          # Get Icetime fields
          length = ((end_datetime - start_datetime)*24*60*60).to_i # multiplies fraction of day by 24, 60 and 60
          start_seconds = ((start_datetime - start_datetime.beginning_of_day)*24*60*60).to_i

          #date = start_datetime.to_date
          date = start_datetime.strftime("%Y-%m-%d")

          # Add the availability to the Avail Tree
          availTree.addAvail(getVenueLocationHash(venue), getTheatreHash(theatre), date, start_seconds, length)

        end

        # Increment rows
        i += 8

      end

    end

    return availTree
  end


end
