class Venue < ActiveRecord::Base
    belongs_to :owner
    has_many :theatres, :dependent => :destroy

    def self.getOpeningsByProxyAndDate(venues_index, venues_limit, origin, openings_from_date, openings_to_date)

        schedule_tree = ScheduleTree.new("Playogo")

        # Only allow 15 venues to be queried at a time (for now)
        if venues_limit > 15
            venues_limit = 15
        end

        sql = """
            SELECT
                subqueryvenues.name as venue_name, 
                subqueryvenues.lat as venue_lat,
                subqueryvenues.long as venue_long,
                subqueryvenues.address as venue_address,
                subqueryvenues.owner_id as owner_id,
                t.name as theatre_name,
                p.prime as prime_price,
                p.non_prime as non_prime_price,
                p.insurance as insurance_price,
                o.date as opening_date,
                o.start_time as opening_start_time,
                o.length as opening_length
            FROM 
            (
                SELECT v.*, SQRT(
                    POW(69.1 * (lat - %s), 2) +
                    POW(69.1 * (%s - long) * COS(lat / 57.3), 2)) AS distance
                FROM venues AS v
                ORDER BY distance asc
                OFFSET %s
                LIMIT %s
            ) AS subqueryvenues
            INNER JOIN theatres AS t ON t.venue_id=subqueryvenues.id
            INNER JOIN openings AS o ON o.theatre_id=t.id
            INNER JOIN prices AS p ON p.theatre_id=t.id
            WHERE o.date >= '%s'
            AND o.date <= '%s';
        """

        prepared_sql = sanitize_sql_array([
            sql,
            origin[:lat],
            origin[:long],
            venues_index,
            venues_limit,
            openings_from_date,
            openings_to_date
        ])

        # r = self.sanitize_sql_array(["SELECT MONTH(created) AS month, YEAR(created) AS year FROM orders WHERE created>=? AND created<=? GROUP BY month ORDER BY month ASC", created1, created2])
        opening_records = self.connection.select_all(prepared_sql)

        opening_records.each do |opening_record|

            schedule_tree.addAvail(
                # Venue
                {
                    :name => opening_record["venue_name"],
                    :lat => opening_record["venue_lat"].to_f,
                    :long => opening_record["venue_long"].to_f,
                    :address => opening_record["venue_address"],
                    :owner => opening_record["owner_id"]
                },
                # Theatre
                {
                    :name => opening_record["theatre_name"],
                    :prime => opening_record["prime_price"].to_i,
                    :non_prime => opening_record["non_prime_price"].to_i,
                    :insurance => opening_record["insurance_price"].to_i
                },
                # Opening
                opening_record["opening_date"],
                opening_record["opening_start_time"].to_i,
                opening_record["opening_length"].to_i
            )

        end

        return schedule_tree

    end

end
