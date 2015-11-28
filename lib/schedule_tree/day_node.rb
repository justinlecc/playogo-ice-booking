class DayNode
  attr_accessor :date, :blocks

  def initialize(date)
    @date = date
    @blocks = []
  end

  def addAvail (startTime, length)
    # Adds the new avail to avails
    new_avail = IcetimeNode.new(startTime, length)
    @blocks.push(new_avail)
  end

  def removeBeforeCutoff(cutoff_time)
    @blocks.delete_if do |block|
      if block.end - 3600 < cutoff_time
        true
      elsif block.start > cutoff_time
        false
      else
        block.length = block.end - cutoff_time
        block.start = cutoff_time

        # Adjust the block if it is an invalid length
        if (block.length % (30*60) != 0)

          if (block.length % 15*60 != 0)
            raise "ERROR: unexpected block length in DayNode::removeBeforeCutoff"
          end

          block.start  += 15*60
          block.length -= 15*60

        end

        false
      end
    end
  end

  def hasAvail

    return @blocks.length > 0;

  end

end
