class BusinessHours

  def initialize
    @open  = 9
    @close = 17
    @approvalBufferHours = 4
  end

  def isHoliday(date)
    return false
  end

  def getApprovalCutoff
    Time.zone = 'Eastern Time (US & Canada)'
    time_s    = (Time.zone.now).to_s
    date_time = DateTime.parse(time_s)
    remainingBufferHours = @approvalBufferHours

    while true

      if (date_time.wday > 0) && (date_time.wday < 6) && (!isHoliday(date_time.strftime("%Y-%m-%d")))

        if (date_time.hour < @open)
          date_time = date_time + (@open - date_time.hour).hours
        elsif (date_time.hour > @close)
          date_time = date_time - date_time.hour.hours + 1.days + @open.hours
        else
          date_time = date_time + 1.hours
          remainingBufferHours -= 1
        end

      else

        date_time = date_time - date_time.hour.hours + 1.days

      end

      if remainingBufferHours == 0
        break
      end

    end

    return_date = date_time.strftime("%Y-%m-%d")
    return_time = date_time.hour * 3600

    return {:date => return_date, :time => return_time}

  end

end

