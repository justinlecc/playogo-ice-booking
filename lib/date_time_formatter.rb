class DateTimeFormatter

  def initialize()
    @short_months = ['Jan','Feb','Mar','Apr','May','June','July','Aug','Sept','Oct','Nov','Dec']
  end

  def shortToMidDateStr(date)

    date_a = date.split('-')
    if date_a.length != 3
      raise "ERROR: date string did not contain 3 components in DateTimeFormatter::shortToMidDateString"
    end

    month_index = date_a[1].to_i - 1
    day_s = date_a[2].to_i.to_s

    #pick up here... attribute not working

    return @short_months[month_index] + ' ' + day_s + ' ' + date_a[0]

  end

  def secondsToTimeStr(seconds)

    hours   = (seconds / 3600) % 24;
    minutes = (seconds % 3600) / 60;

    if (seconds % 60) != 0
      raise "ERROR: seconds that weren't a multiple of 60 were passed into TimeFormatting::secondsToTimeString"
    elsif minutes > 59
      raise "ERROR: minutes > 59 in TimeFormatting::secondsToTimeString"
    end

    hours_s   = ''
    minutes_s = ''
    postfix   = ''

    # Get hours string
    if hours == 0
      hours_s = '12'
      postfix = 'am'
    elsif hours < 12
      hours_s = hours.to_s
      postfix = 'am'
    elsif hours == 12
      hours_s = '12'
      postfix = 'pm'
    else
      hours_s = (hours % 12).to_s
      postfix = 'pm'
    end

    # Get minutes string
    if minutes < 10
      minutes_s = '0' + minutes.to_s
    else
      minutes_s = minutes.to_s
    end

    return hours_s + ':' + minutes_s + postfix
  end
end