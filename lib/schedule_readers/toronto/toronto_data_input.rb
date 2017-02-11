class TorontoDataInput < DataIngestion

    def initialize()

        super()

        @owner_name      = "Toronto"
        @owner_long_name = "City of Toronto"
        @manager_name    = "Toronto Manager"
        @manager_email   = "playogosports@gmail.com"

    end

    def getVenueLocationHash(venue_name) 
        lat = nil
        long = nil
        address = nil

        if (venue_name == "Agincourt Recreation Centre"); 
            lat = 43.7880479
            long = -79.2762419
            address = "31 Glen Watford Dr, Scarborough, ON M1S 2B7, Canada"


        elsif (venue_name == "Albion Arena"); 
            lat = 43.7395848
            long = -79.5827553
            address = "1501 Albion Rd, Etobicoke, ON M9V 1B2, Canada"


        elsif (venue_name == "Amesbury Sports Complex"); 
            lat = 43.7060646
            long = -79.4867638
            address = "155 Culford Rd, North York, ON M6M 4K6, Canada"


        elsif (venue_name == "Angela James Arena - Flemingdon"); 
            lat = 43.7129011
            long = -79.3279516
            address = "165 Grenoble Dr, North York, ON M3C 3E7, Canada"


        elsif (venue_name == "Baycrest Arena"); 
            lat =  43.729383
            long = -79.441302
            address = "160 Neptune Dr, Toronto, ON M6A, Canada"


        elsif (venue_name == "Bayview Arena"); 
            lat = 43.7879525
            long = -79.3937839
            address = "3230 Bayview Ave, North York, ON M2M 3R7, Canada"


        elsif (venue_name == "Centennial Recreation Centre-Scarborough"); 
            lat = 43.7746687
            long = -79.2367925
            address = "1967 Ellesmere Rd, Scarborough, ON M1H 2W4, Canada"


        elsif (venue_name == "Central Arena"); 
            lat = 43.6496507
            long = -79.5200823
            address = "50 Montgomery Rd, Toronto, ON, Canada"


        elsif (venue_name == "Chris Tonks Arena"); 
            lat = 43.6749797
            long = -79.5023841
            address = "95 Black Creek Blvd, York, ON M6N 2K6, Canada"


        elsif (venue_name == "Commander Recreation Centre"); 
            lat = 43.7948497
            long = -79.2686725
            address = "140 Commander Blvd, Scarborough, ON M1S, Canada"


        elsif (venue_name == "Don Mills Civitan Arena"); 
            lat = 43.7331436
            long = -79.3431905
            address = "1030 Don Mills Rd, North York, ON M3C 1W6, Canada"


        elsif (venue_name == "Don Montgomery Community Centre"); 
            lat = 43.7328235
            long = -79.2611697
            address = "2467 Eglinton Ave E, Scarborough, ON M1K 2R1, Canada"


        elsif (venue_name == "Downsview Arena"); 
            lat =  43.719039
            long = -79.512625
            address = "1633 Wilson Ave, North York, ON M3L 1A5, Canada"


        elsif (venue_name == "East York Memorial Arena"); 
            lat = 43.6968688
            long = -79.3155956
            address = "888 Cosburn Ave, Toronto, ON M4C, Canada"


        elsif (venue_name == "Fenside Arena"); 
            lat = 43.7636582
            long = -79.3266075
            address = "30 Slidell Crescent, North York, ON M3A 2C4, Canada"


        elsif (venue_name == "Gord And Irene Risk Community Centre"); 
            lat = 43.7474296
            long = -79.5664765
            address = "2650 Finch Ave W, North York, ON M9M 3A3, Canada"


        elsif (venue_name == "Goulding Community Centre"); 
            lat = 43.7906023
            long = -79.4221644
            address = "45 Goulding Ave, North York, ON M2M 3W8, Canada"


        elsif (venue_name == "Grandravine Community Recreation Centre"); 
            lat =  43.751882
            long = -79.490567
            address = "23 Grandravine Dr, North York, ON M3J 1B3, Canada"


        elsif (venue_name == "Habitant Arena"); 
            lat =  43.746955
            long = -79.540259
            address = "3383 Weston Rd, North York, ON M9M 2P4, Canada"


        elsif (venue_name == "Herbert H.Carnegie Centennial Centre"); 
            lat = 43.7731141
            long = -79.4501359
            address = "580 Finch Ave W, North York, ON M2R 1N7, Canada"


        elsif (venue_name == "Heron Park Community Centre"); 
            lat = 43.7684158
            long = -79.1753942
            address = "292 Manse Rd, Scarborough, ON M1E 3V4, Canada"


        elsif (venue_name == "John Booth Arena"); 
            lat = 43.7697505
            long = -79.524081
            address = "230 Gosford Blvd, North York, ON M3N 2H1, Canada"


        elsif (venue_name == "Lambton Arena"); 
            lat = 43.6638348
            long = -79.5035552
            address = "4100 Dundas St W, Toronto, ON M6S, Canada"


        elsif (venue_name == "Long Branch Arena"); 
            lat = 43.5917314
            long = -79.5259113
            address = "75 Arcadian Cir, Etobicoke, ON M8W 2Y9, Canada"


        elsif (venue_name == "Malvern Recreation Centre"); 
            lat = 43.8078999
            long = -79.2160922
            address = "30 Sewells Rd, Scarborough, ON M1B 3G5, Canada"


        elsif (venue_name == "McGregor Park Community Centre"); 
            lat = 43.7474922
            long = -79.2801286
            address = "2231 Lawrence Ave E, Scarborough, ON M1P 2P5, Canada"


        elsif (venue_name == "Mimico Arena"); 
            lat =  43.612401
            long = -79.498800
            address = "31 Drummond St, Etobicoke, ON M8V 1Y7, Canada"


        elsif (venue_name == "Mitchell Field Community Centre"); 
            lat = 43.7748849
            long = -79.4084371
            address = "89 Church Ave, North York, ON M2N 6C9, Canada"


        elsif (venue_name == "Phil White Arena"); 
            lat =  43.691273
            long = -79.431419
            address = "443 Arlington Ave, York, ON M6C 3A2, Canada"


        elsif (venue_name == "Pleasantview Community Centre"); 
            lat = 43.7869705
            long = -79.3367815
            address = "545 Van Horne Ave, North York, ON M2J 4S8, Canada"


        elsif (venue_name == "Roding Community Centre"); 
            lat = 43.7290772
            long = -79.4920293
            address = "600 Roding St, North York, ON M3M 2A6, Canada"


        elsif (venue_name == "Scarborough Village Recreation Centre"); 
            lat = 43.7401414
            long = -79.2168204
            address = "3600 Kingston Rd, Scarborough, ON M1M 1R9, Canada"


        elsif (venue_name == "Victoria Village Arena"); 
            lat =  43.723177
            long = -79.315563
            address = "190 Bermondsey Rd, North York, ON M4A 1Y1, Canada"


        elsif (venue_name == "York Mills Arena"); 
            lat = 43.7466298
            long = -79.3838918
            address = "2539 Bayview Ave, North York, ON M2L, Canada"

        elsif (venue_name == "Birchmount Community Centre");
            lat = 45.1510532655634
            long = -79.398193359375
            address = "93 Birchmount Rd, Scarborough, ON M1N 3J7"

        elsif (venue_name == "Centennial Arena (Etobicoke/York)");
            lat = 43.4581759
            long = -80.5255042
            address = "156 Centennial Park Rd, Etobicoke, ON M9C 5N3"

        elsif (venue_name == "Cummer Park Community Centre");
            lat = 43.4581759
            long = -80.5255042
            address = "6000 Leslie St, North York, ON M2H"

        elsif (venue_name == "Oriole Community Centre");
            lat = 43.4581759
            long = -80.5255042
            address = "2975 Don Mills Rd, North York, ON M2J"

        elsif (venue_name == "Park Lawn Rink");
            lat = 43.4581759
            long = -80.5255042
            address = "340 Park Lawn Rd, Toronto, ON M8Y 3K4"

        elsif (venue_name == "Pine Point Arena");
            lat = 43.7126479
            long = -79.5427477
            address = "15 Grierson Rd, Etobicoke, ON M9W 3R2"
        else
            throw "ERROR: Invalid venue name in getVenueLocationHash(): " + venue_name
        end

        return {:name => venue_name, :lat => lat, :long => long, :address => address}

    end

    def fetchHtml()

        # The file we are writing the data to
        output_file = Rails.root.join('lib', 'schedule_readers', 'toronto', 'output.html')

        # ============================================================
        # Step 1
        # Gets link for online facilities schedule with updated params
        # ============================================================

        # Get web page
        # response = HTTParty.get('http://www.waterloo.ca/en/gettingactive/facilitiesandrooms.asp',
        #     :headers => {
        #         'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        #         'Accept-Encoding' => 'gzip, deflate, sdch',
        #         'Accept-Language' => 'en-US,en;q=0.8', 
        #         'Cache-Control' => 'max-age=0',
        #         'Connection' => 'keep-alive',
        #         'Host' => 'www.waterloo.ca',
        #         'Upgrade-Insecure-Requests' => '1',
        #         'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36'
        #     },
        #     :limit => 1
        # )

        # Parse web page
        # parsed_page = Nokogiri::HTML(response)

        # Grab correct link from page
        # possible_links = parsed_page.css('#printAreaContent .PlainText a')

        #link = 'https://efun.toronto.ca/torontofun/Facilities/FacilitiesSearchWizard.asp'

        # possible_links.each do |possible_link|

        #     if (possible_link.text == 'availability')

        #         link = possible_link['href']

        #     end

        # end

        # =====================================================================
        # Step 2
        # Navige to facility availability schedule while collecting the cookies
        # =====================================================================
        search_page_url = 'https://efun.toronto.ca/torontofun/Facilities/FacilitiesSearchWizard.asp'

        # # Get page
        response = HTTParty.get(search_page_url, 
            :headers => {
                'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Encoding' => 'gzip, deflate',
                'Accept-Language' => 'en-US,en;q=0.5',
                'Connection' => 'keep-alive',
                'Host' => 'efun.toronto.ca',
                # 'Referer' => 'http://www.waterloo.ca/en/gettingactive/facilitiesandrooms.asp',
                'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:41.0) Gecko/20100101 Firefox/41.0'
            },
            :limit => 3
        )

        # # Collect the cookies
        cookies = HTTParty::CookieHash.new
        if (response.request.options[:headers]["Cookie"])
            cookies.add_cookies response.request.options[:headers]["Cookie"]
        end

        # ====================================
        # Step 3
        # Get the first page of availabilities
        # ====================================
        search_page_url = 'https://efun.toronto.ca/torontofun/Facilities/FacilitiesSearchResult.asp'

        # Get the current date information
        Time.zone = 'Eastern Time (US & Canada)'
        current_day = Time.zone.now.day
        current_month = Time.zone.now.month
        current_year = Time.zone.now.year
        current_date = DateTime.parse(Time.zone.now.to_s).strftime("%d/%m/%Y")

        # Get the date we are searching to
        search_to_date = DateTime.new(@search_to_year, @search_to_month, @search_to_day).strftime("%d/%m/%Y")

        # Get the webpage
        response = HTTParty.post(search_page_url,
            # :query => { :SCheck => scheck, :SDT => sdt, :ajax => 1},
            :query => { :ajax => 1},
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
                'chkWeekDay8' => '7',
                'TimeFrom' => '6',
                'AMPMFrom' => '0',
                'TimeTo' => '10',
                'AMPMTo' => '1',
                'FacilityLengthHours' => '1',
                'FacilityLengthMinutes' => '00',
                'FacilityFunctions' => '32',
                'CapacityPieces' => nil,
                'FacilitySpots' => nil,
                'FacilityTypes' => nil,
                'FacilityComplexs' => nil,
                'ajax' => true
                    
            },
            :headers => {
                'Accept' => 'text/html, */*; q=0.01',
                'Accept-Encoding' => 'gzip, deflate, br',
                'Accept-Language' => 'en-US,en;q=0.8',
                'Connection' => 'keep-alive',
                # 'Content-Length' => '325',
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Cookie' => cookies.to_cookie_string,
                'Host' => 'efun.toronto.ca',
                'Origin' => 'https://efun.toronto.ca',
                'Referer' => 'https://efun.toronto.ca/torontofun/Facilities/FacilitiesSearchWizard.asp',
                'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36',
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
            response = HTTParty.post(search_page_url,
                    :body => {
                        'SearchFor' => 'A',
                        'iDisplayStart' => i_display_start,
                        'iDisplayLength' => i_display_length,
                        'iCurrentPageNumber' => page_number,
                        'ajax' => true,
                    },
                    :headers => {
                        'Accept' => 'text/html, */*; q=0.01',
                        'Accept-Encoding' => 'gzip, deflate, br',
                        'Accept-Language' => 'en-US,en;q=0.8',
                        'Connection' => 'keep-alive',
                        'Content-Length' => '74',
                        'Content-Type' => 'application/x-www-form-urlencoded',
                        'Cookie' => cookies.to_cookie_string,
                        'Host' => 'efun.toronto.ca',
                        'Origin' => 'https://efun.toronto.ca',
                        'Referer' => 'https://efun.toronto.ca/torontofun/Facilities/FacilitiesSearchWizard.asp',
                        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36',
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
