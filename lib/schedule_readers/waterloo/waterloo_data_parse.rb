class WaterlooDataParse

  def initialize()
    @search_to_day   = 31
    @search_to_month = 3
    @search_to_year  = 2016

    @month_name_to_digit = {"Jan" => 1, "Feb" => 2, "Mar" => 3, "Apr" => 4, 
                            "May" => 5, "Jun" => 6, "Jul" => 7, "Aug" => 8, 
                            "Sep" => 9, "Oct" => 10,"Nov" => 11,"Dec" => 12}

    @owner_name      = "Waterloo"
    @owner_long_name = "City of Waterloo"
    @manager_name    = "Ashley Kropf"
    @manager_email   = "playogosports@gmail.com"

  end

  def getTheatreHash(theatre)
    return {:prime => 20000, :non_prime => 15000, :insurance => 500, :name => theatre}
  end

  def getVenueLocationHash(venue) 
    lat = nil
    long = nil
    address = nil
    if (venue == "Waterloo Memorial Recreation Complex")
      lat = 43.464093
      long = -80.532588
      address = "101 Father David Bauer Dr, Waterloo, ON N2J 4A8, Canada"
    elsif (venue == "RIM Park")
      lat = 43.519172
      long = -80.502067
      address = "2001 University Ave E, Waterloo, ON N2K 4K4, Canada"
    elsif (venue == "Moses Springer Community Centre")
      lat = 43.473331
      long = -80.511332
      address = "150 Lincoln Rd, Waterloo, ON N2J 4A8, Canada"
    elsif (venue == "Albert McCormick C.C.")
      lat = 43.488927
      long = -80.544575
      address = "500 Parkside Dr, Waterloo, ON N2L 5J4, Canada"
    else
      throw "ERROR: Invalid venue name in getVenueLocationHash()"
    end
    return {:name => venue, :lat => lat, :long => long, :address => address}
  end

  def load(xmlFile)
    treeToDatabase(xmlToTree(xmlFile))
  end

  def loadLocal()
    treeToDatabase(htmlToTree('output.html'))
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

              theatres.each do |theatre| 

                theatre.openings.delete_all

                if (theatre.price)
                  theatre.price.delete
                end

              end

              # Delete the theatres
              theatres.delete_all

            end

          end

          # Delete the venues
          venues.delete_all

        end

        owner.delete
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
      owner = Owner.create!({:name            => @owner_name,
                             :long_name => @owner_long_name,
                             :manager_name    => @manager_name,
                             :manager_email   => @manager_email});
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

          Price.create!({:prime => 20000, :non_prime => 15000, :insurance => 533, :theatre => cur_theatre}) # TODO: make price models

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
  
  def htmlToTree(htmlFile)

    # Structure to hold availabilities
    availTree = ScheduleTree.new("Waterloo")

    # File name of doc to be parsed should be param 
    doc_path = Rails.root.join('lib', 'schedule_readers', 'waterloo', htmlFile)
    
    # Get xml into Nokogiri format
    doc = Nokogiri::XML(File.read(doc_path))

    # Iterate through each page
    pages = doc.css("body")
    page_number = 1

    pages.each do |page|

      table = page.css("table")

      # Check if its the first page which has a table and header
      if (table.length != 0)

        # Get rows we want from the first page
        rows = page.css("table > tbody > tr")

      else

        # Get rows we want from subsequent pages
        rows = page.css("tr")

      end

      page_number += 1

      rows.each do |row|

        # Get cells
        cells = row.css("td")

        # Get venue
        venue = cells[0].inner_text

        # Get theatre
        theatre = cells[1].css("li")[0].inner_text

        # Get date (dd-mm-yyyy)
        date = cells[3].css("a")[0].inner_text.split("-")
        month = date[0]
        day = date[1]
        year = date[2]
        date = year + "-" + month + "-" + day

        # Get start and end time
        timeslot = cells[4].inner_text.split("-")
        start_time = timeslot[0]
        end_time = timeslot[2]

        # Create datetimes
        start_datetime = DateTime.strptime(date + " " + start_time, "%Y-%b-%d %H:%M%p")
        end_datetime   = DateTime.strptime(date + " " + end_time, "%Y-%b-%d %H:%M%p")

        # Get date string
        date_string = start_datetime.strftime("%Y-%m-%d")

        # Assert that start_datetime is before end_datetime
        if (start_datetime >= end_datetime)
          raise "ERROR: start_datetime is later than end_datetime"
        end

        # Get Icetime fields
        length = ((end_datetime - start_datetime)*24*60*60).to_i # multiplies fraction of day by 24, 60 and 60
        start_seconds = ((start_datetime - start_datetime.beginning_of_day)*24*60*60).to_i

        # Length should be a multiple of a half hour
        remainder = length % (30 * 60)
        if (remainder != 0)

          # Seems to be only a few thursday mornings in January... keep and eye on this
          puts "============================================================================"
          puts "NOT HALF HOUR:"
          puts venue + " -> " + theatre
          puts "Start time: " + start_datetime.to_s
          puts "Length in hours: " + (length / (3600.00)).to_s
          puts "============================================================================"

          # Make correct length
          start_seconds += remainder
          length -= remainder

          if (length < 3600)
            raise "ERROR: shortening the length made the booking too short!"
          end

        end

        puts venue + " | " + theatre

        # Add the availability to the Avail Tree
        availTree.addAvail(getVenueLocationHash(venue), getTheatreHash(theatre), date_string, start_seconds, length)

      end

    end

    return availTree

  end

  def fetchHtml()

    # The file we are writing the data to
    output_file = Rails.root.join('lib', 'schedule_readers', 'waterloo', 'output.html')

    # ============================================================
    # Step 1
    # Gets link for online facilities schedule with updated params
    # ============================================================

    # Get web page
    response = HTTParty.get('http://www.waterloo.ca/en/gettingactive/facilitiesandrooms.asp',
      :headers => {
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Encoding' => 'gzip, deflate, sdch',
        'Accept-Language' => 'en-US,en;q=0.8', 
        'Cache-Control' => 'max-age=0',
        'Connection' => 'keep-alive',
        'Host' => 'www.waterloo.ca',
        'Upgrade-Insecure-Requests' => '1',
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36'
      },
      :limit => 1
    )

    # Parse web page
    parsed_page = Nokogiri::HTML(response)

    # Grab correct link from page
    possible_links = parsed_page.css('#printAreaContent .PlainText a')

    link = ''

    possible_links.each do |possible_link|

      if (possible_link.text == 'availability')

        link = possible_link['href']

      end

    end

    # =====================================================================
    # Step 2
    # Navige to facility availability schedule while collecting the cookies
    # =====================================================================

    # Get page
    response = HTTParty.get(link, 
      :headers => {
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Encoding' => 'gzip, deflate',
        'Accept-Language' => 'en-US,en;q=0.5',
        'Connection' => 'keep-alive',
        'Host' => 'expressreg.city.waterloo.on.ca',
        'Referer' => 'http://www.waterloo.ca/en/gettingactive/facilitiesandrooms.asp',
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:41.0) Gecko/20100101 Firefox/41.0'
      },
      :limit => 3
    )

    # Collect the cookies
    cookies = HTTParty::CookieHash.new
    if (response.request.options[:headers]["Cookie"])
      cookies.add_cookies response.request.options[:headers]["Cookie"]
    end

    # Parse the web page
    parsed_page = Nokogiri::HTML(response)

    # Get the session variables
    scheck = parsed_page.css('#SCheck')[0]['value']
    sdt    = parsed_page.css('#SDT')[0]['value']

    # ====================================
    # Step 3
    # Get the first page of availabilities
    # ====================================

    # Get the current date information
    Time.zone = 'Eastern Time (US & Canada)'
    current_day = Time.zone.now.day
    current_month = Time.zone.now.month
    current_year = Time.zone.now.year
    current_date = DateTime.parse(Time.zone.now.to_s).strftime("%d-%m-%Y")

    # Get the date we are searching to
    search_to_date = DateTime.new(@search_to_year, @search_to_month, @search_to_day).strftime("%d-%m-%Y")

    # Get the webpage
    response = HTTParty.post("https://expressreg.city.waterloo.on.ca/facilities/FacilitiesSearchResult.asp",
        :query => { :SCheck => scheck, :SDT => sdt, :ajax => 1},
        :body => {
          'SearchFor' => 'A',
          'DayFrom' => current_day,
          'MonthFrom' => current_month,
          'YearFrom' => current_year,
          'DateFrom' => current_date,
          'DayTo' => @search_to_day,
          'MonthTo' => @search_to_month,
          'YearTo' => @search_to_year,
          'DateTo' => @search_to_date,
          'TimeFrom' => 6,
          'AMPMFrom' => 0,
          'TimeTo' => 11, # wloo online avails search doesn't allow any later
          'AMPMTo' => 1,
          'FacilityLengthHours' => 1,
          'FacilityLengthMinutes' => 0,
          'chkWeekDay8' => 7,
          'FacilityFunctions' => 686,
          'CapacityPieces' => nil,
          'FacilitySpots' => nil,
          'FacilityTypes' => nil,
          'FacilityComplexs' => nil,
          'ajax' => true,
        },
        :headers => {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:41.0) Gecko/20100101 Firefox/41.0',
          'Cookie' => cookies.to_cookie_string,
          'Accept' => 'text/html, */*',
          'Accept-Encoding' => 'gzip, deflate',
          'Accept-Language' => 'en-US,en;q=0.5',
          'Cache-Control' => 'no-cache',
          'Connection'  => 'keep-alive',
          'Content-Length' =>  '77',
          'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
          'Host' => 'expressreg.city.waterloo.on.ca',
          'Pragma' => 'no-cache',
          'Referer' => link,
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:41.0) Gecko/20100101 Firefox/41.0',
          'X-Requested-With' => 'XMLHttpRequest'
        }
    )

    # Parse the page and write it to file
    parsed_page = Nokogiri::HTML(response)
    File.write(output_file, parsed_page)

    # ====================================
    # Step 4
    # Get the rest of the availabilities
    # ====================================

    page_number = 2 # Got page 1 above

    while (true)

      # Calculate the values we need to send to Waterloo's server
      i_display_start = ((page_number - 1) * 10) + 1
      i_display_length = 10

      # Get the webpage
      response = HTTParty.post("https://expressreg.city.waterloo.on.ca/facilities/FacilitiesSearchResult.asp",
          :query => { :SCheck => scheck, :SDT => sdt, :ajax => 1},
          :body => {
            'SearchFor' => 'A',
            'iDisplayStart' => i_display_start,
            'iDisplayLength' => i_display_length,
            'iCurrentPageNumber' => page_number,
            'ajax' => true,
          },
          :headers => {
            'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:41.0) Gecko/20100101 Firefox/41.0',
            'Cookie' => cookies.to_cookie_string,
            'Accept' => 'text/html, */*',
            'Accept-Encoding' => 'gzip, deflate',
            'Accept-Language' => 'en-US,en;q=0.5',
            'Cache-Control' => 'no-cache',
            'Connection'  => 'keep-alive',
            'Content-Length' =>  '77',
            'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
            'Host' => 'expressreg.city.waterloo.on.ca',
            'Pragma' => 'no-cache',
            'Referer' => link,
            'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:41.0) Gecko/20100101 Firefox/41.0',
            'X-Requested-With' => 'XMLHttpRequest'
          }
      )

      # Parse the webpage
      parsed_page = Nokogiri::HTML(response)

      # Check if the webpage is empty (stop requesting)
      if (parsed_page.css('html').length == 0)
        puts "No more pages to fetch."
        break
      else
        puts "Page: " + page_number.to_s
      end

      # Append the page to file
      open(output_file, 'a') do |f|
        f.puts parsed_page
      end

      # Goto the next page
      page_number += 1

    end

    puts "Done."

  end

end
