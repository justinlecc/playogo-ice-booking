module Bookable
  
  # Remove any openings from the schedule tree that overlap with the booking
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
    scheduleTree.venues.each do |venue|
      if venue.name == booking.theatre.venue.name
        venue.theatres.each do |theatre|
          if theatre.name == booking.theatre.name
            theatre.days.each do |day|
              if day.date == booking.date
                blocks_to_add = []
                day.blocks.each_with_index do |block, index|
                  a = block
                  b = booking

                  # Case 1
                  if (b.start_time <= a.start)
                    # 1.i (total overlap)
                    if (b.end_time >= a.end)
                      day.blocks[index] = nil

                    # 1.ii (partial overlap)
                    elsif (b.end_time > a.start)
                      old_start_time = block.start
                      block.start = b.end_time
                      block.length = block.length - (block.start - old_start_time)
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
                      block.length = b.start_time - a.start 
                    # 2.ii (splice)
                    else
                      a1_start = a.start
                      a1_length = b.start_time - a.start
                      a1 = IcetimeNode.new(a1_start, a1_length)
                      blocks_to_add.push(a1)
                      a2_start = b.end_time
                      a2_length = a.end - b.end_time
                      a2 = IcetimeNode.new(a2_start, a2_length)
                      blocks_to_add.push(a2)
                      day.blocks[index] = nil
                    end
                  end  
                end#end block loop
                # Put add back the spliced blocks
                blocks_to_add.each do |b|
                  day.blocks.push(b)
                end

                # Remove any blocks less than 1 hour
                day.blocks.each_with_index do |b, index|
                  if b != nil
                    if b.length < 1.hour
                      day.blocks[index] = nil
                    end
                  end
                end
                # Clear out all nils
                day.blocks.compact!
                break
              end
            end#end day loop
            break
          end
        end#end theatre
        break
      end
    end#end venue loop
  end#end adjustOpenings

  # Return all bookable ice time
  def self.getBookable
    scheduleTree = ScheduleTree.new("Playogo")
    # Get all openings into schedule tree
    venues = Venue.all
    venues.each do |venue|
      venue.theatres.each do |theatre|
        theatre.openings.each do |opening|
          scheduleTree.addAvail({:name => venue.name,
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

    # Adjust openings according to each booking
    bookings = Booking.all
    bookings.each do |booking|
      adjustOpenings(booking, scheduleTree)
    end

    return scheduleTree
  end
end