module Bookable
  
  # Remove any openings that overlap with booking
  def self.adjustOpenings(booking, scheduleTree)
    # Two cases (comparing booking b to opening a):
    #    1. b.start_time <= a.start_time
    #        i. delete a
    #        ii. remove start of a
    #        iii. do nothing
    #    
    #    2. b.start_time > a.start_time
    #        i. remove ending of a
    #        ii. do nothing
    #        iii. splice a
    scheduleTree.owners.each do |owner|
      if owner.name == booking.theatre.venue.owner.name
        owner.venues.each do |venue|
          if venue.name == booking.theatre.venue.name
            venue.theatres.each do |theatre|
              if theatre.name == booking.theatre.name
                theatre.days.each do |day|
                  if day.date == booking.date
                    openings_to_add = []
                    day.openings.each_with_index do |opening, index|
                      a = opening
                      b = booking

                      # Case 1
                      if (b.start_time <= a.start)
                        # 1.i (total overlap)
                        if (b.end_time >= a.end)
                          day.openings[index] = nil

                        # 1.ii (partial overlap)
                        elsif (b.end_time > a.start)
                          old_start_time = opening.start
                          opening.start = b.end_time
                          opening.length = opening.length - (opening.start - old_start_time)
                        # 1.iii (no overlap)
                        else
                          # do nothing
                        end

                      # Case 2
                      else
                        # 2.iii (no overlap)
                        if (b.start_time >= a.end)
                          # do nothing
                        # 2.i (partial overlap)
                        elsif (b.end_time >= a.end)
                          opening.length = b.start_time - a.start 
                        # 2.ii (splice)
                        else
                          a1_start = a.start
                          a1_length = b.start_time - a.start
                          a1 = OpeningNode.new(a1_start, a1_length)
                          openings_to_add.push(a1)
                          a2_start = b.end_time
                          a2_length = a.end - b.end_time
                          a2 = OpeningNode.new(a2_start, a2_length)
                          openings_to_add.push(a2)
                          day.openings[index] = nil
                        end
                      end  
                    end#end opening loop
                    # Put add back the spliced openings
                    openings_to_add.each do |b|
                      day.openings.push(b)
                    end

                    # Remove any openings less than 1 hour
                    day.openings.each_with_index do |b, index|
                      if b != nil
                        if b.length < 1.hour
                          day.openings[index] = nil
                        end
                      end
                    end
                    # Clear out all nils
                    day.openings.compact!
                    break
                  end
                end#end day loop
                break
              end
            end#end theatre
            break
          end
        end#end venue loop
        break
      end
    end#end of owner loop
  end#end adjustOpenings

  # Return all bookable ice time
  def self.getBookable
    scheduleTree = ScheduleTree.new()
    # Get all openings into schedule tree
    owners = Owner.all
    owners.each do |owner|
      owner.venues.each do |venue|
        venue.theatres.each do |theatre|
          theatre.openings.each do |opening|
            scheduleTree.addOpening({:name => owner.name},
                                  {:name => venue.name,
                                   :lat => venue.lat,
                                   :long => venue.long,
                                   :address => venue.address},
                                  {:name => theatre.name,    
                                   :prime => theatre.price.prime,
                                   :non_prime => theatre.price.non_prime,
                                   :insurance => theatre.price.insurance},
                                  opening.date.to_s, 
                                  opening.start_time, 
                                  opening.length)
          end
        end
      end
    end

    # Adjust openings according to each booking
    bookings = Booking.all
    bookings.each do |booking|
      adjustOpenings(booking, scheduleTree)
    end

    return scheduleTree
  end
end