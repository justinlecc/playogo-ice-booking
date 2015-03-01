
class KitchenerDataParse  
  def load
    xmlFile = 'kitchener_data.xml'
    treeToDatabase(xmlToTree(xmlFile))
  end

  def treeToDatabase (availTree)
    # Delete current avails
    Opening.delete_all
    Theatre.delete_all
    Venue.delete_all

    # Create new avails
    availTree.venues.each do |venue|
      @cur_venue = Venue.create!({:name => venue.name});
      venue.theatres.each do |theatre|
        @cur_theatre = Theatre.create!({:name => theatre.name, :venue => @cur_venue})
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
          availTree.addAvail(venue, theatre, date, start_seconds, length)

        end

        # Increment rows
        i += 8

      end

    end

    return availTree
  end


end
