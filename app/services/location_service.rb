class LocationService

    def initialize

    end

    def get_lat_long(postal)
        return {
            lat: 43.653226,
            long: -79.383184
        }
    end

    def get_schedule_tree_with_driving_distances(origin, schedule_tree)

        origins_string = origin[:lat].to_s + "," + origin[:long].to_s
        destinations_string = ''

        schedule_tree.venues.each_with_index do |venue, i|

            destinations_string += venue.lat.to_s + "," + venue.long.to_s

            if i < schedule_tree.venues.length - 1

                destinations_string += "|"

            end

        end

        response = HTTParty.get(
            'https://maps.googleapis.com/maps/api/distancematrix/json', 
            query: {
                units: 'imperial',
                origins: origins_string,
                destinations: destinations_string,
                key: ENV['PLAYOGO_GMAPS_API_KEY']
            }
        )

        response["rows"][0]["elements"].each_with_index do |element, i|

            if element['status'] != "NOT_FOUND"
                schedule_tree.venues[i].duration_text = element['duration']['text']
                schedule_tree.venues[i].duration_value = element['duration']['value']
            end

        end

        schedule_tree.venues.sort! { |v1,v2| v1.duration_value <=> v2.duration_value }

        return schedule_tree

    end 

end