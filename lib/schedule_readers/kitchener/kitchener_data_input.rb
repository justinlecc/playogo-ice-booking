
class KitchenerDataInput  

  def initialize()

    @owner_name      = "Kitchener"
    @owner_long_name = "City of Kitchener"

    @manager_name    = "Dan Walkling"
    @manager_email   = "info@theaud.ca"

    @processing_hours = 8

    @price_prime     = 23673
    @price_non_prime = 13421
    @price_insurance = 540

  end

  def getTheatreHash(theatre)
    return {:prime => @price_prime, :non_prime => @price_non_prime, :insurance => @price_insurance, :name => theatre}
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

  def load(xmlFile)
    treeToDatabase(xmlToTree(xmlFile))
  end

  def treeToDatabase (availTree) # method should be in a superclass

    owner = Owner.where(name: @owner_name).first

    # 'clear_data' is set to if we want to delete the model we have and start fresh.
    # Should be false in production because we only want to update openings.
    clear_data = true

    if (clear_data)

      # Delete the whole model
      if (owner)

        venues = owner.venues

        if (venues.length > 0)

          venues.each do |venue|

            theatres = venue.theatres

            if (theatres.length > 0)
              puts "in here 1"
              theatres.each do |theatre| 
                puts "in here 2"
                theatre.openings.destroy_all
                theatre.bookings.destroy_all

                if (theatre.price)
                  puts "in here 3"
                  theatre.price.destroy
                end

              end

              # Delete the theatres
              puts "in here 4"
              theatres.destroy_all

            end

          end

          # Delete the venues
          venues.destroy_all

        end

        owner.destroy
        owner = nil

      end

    else

      # Delete only the openings
      if (owner)

        venues = owner.venues

        venues.each do |venue|

          theatres = venue.theatres

          theatres.each do |theatre| 

            # Clear the current openings
            theatre.openings.delete_all

          end

        end

      end

    end

    # Create the owner record if it is has been deleted (or hasn't existsed yet)
    if (!owner)
      owner = Owner.create!({:name             => @owner_name,
                             :long_name        => @owner_long_name,
                             :manager_name     => @manager_name,
                             :manager_email    => @manager_email,
                             :processing_hours => @processing_hours});
    end

    # Create new avails
    availTree.venues.each do |venue|

      if (clear_data)

        locationHash = getVenueLocationHash(venue.name) 

        cur_venue = Venue.create!({:name     => venue.name, 
                                    :owner   => owner,
                                    :lat     => venue.lat,
                                    :long    => venue.long, #locationHash[:long],
                                    :address => venue.address}) #locationHash[:address]});

      else

        cur_venue = Venue.find({:name => venue.name}).first;

      end

      venue.theatres.each do |theatre|

        if (clear_data) 

          cur_theatre = Theatre.create!({:name => theatre.name, :venue => cur_venue})

          Price.create!({:prime => @price_prime, :non_prime => @price_non_prime, :insurance => @price_insurance, :theatre => cur_theatre}) # TODO: make price models

        else

          cur_theatre = Theatre.find({:name => theatre.name, :venue => cur_venue})

        end

        theatre.days.each do |day|

          day.blocks.each do |block|

            Opening.create!({:start_time => block.start, 
                             :length     => block.length, 
                             :date       => day.date,
                             :theatre    => cur_theatre})
          end

        end

      end

    end
  end
  
  def xmlToTree(xmlFile)
    # Structure to hold availabilities
    availTree = ScheduleTree.new("Kitchener")

    # File name of doc to be parsed should be param 
    doc_path = Rails.root.join('lib', 'schedule_readers', 'kitchener', xmlFile)

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
          end_datetime   = DateTime.strptime(end_date + " " + end_time, "%d %b %Y %H:%M %p")

          # Assert that start_datetime is before end_datetime
          if (start_datetime >= end_datetime)
            raise "ERROR: start_datetime is later than end_datetime"
          end

          # Get Icetime fields
          length = ((end_datetime - start_datetime)*24*60*60).to_i # multiplies fraction of day by 24, 60 and 60
          start_seconds = ((start_datetime - start_datetime.beginning_of_day)*24*60*60).to_i

          # Trim availability with invalid length
          # This is due to the staggered start of Kitcheners pads.
          # They don't account for it in their schedules
          odd_length = length % (30*60);
          if (odd_length != 0)
            if odd_length != 15*60
              raise "ERROR: Invalid availability length was not off by 15 mins"
            end

            # Cut off begining of morning availabilities
            if start_seconds < (12*3600)
              start_seconds += 15*60
              length -= 15*60

            # Cut off end of late day availabilities
            else
              length -= 15*60
    
            end
          end

          #date = start_datetime.to_date
          date = start_datetime.strftime("%Y-%m-%d")

          # Add the availability to the Avail Tree
          availTree.addAvail(getVenueLocationHash(venue), getTheatreHash(theatre), date, start_seconds, length)

        end

        # Increment row
        i += 8

      end

    end

    return availTree
  end


end
