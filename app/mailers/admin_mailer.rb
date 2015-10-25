class AdminMailer < ApplicationMailer

  # Email sent to admin
  def notify_admin(info)

    if info[:type] == "BOOKING_CANCELLATION"
        @message = "Booking " + info[:booking_id].to_s + " has been cancelled."
    elsif info[:type] == "BOOKING_CONFIRMATION"
        @message = "Booking " + info[:booking_id].to_s + " has been confirmed."
    elsif info[:type] == "BOOKING_REQUEST"
        @message = "Booking " + info[:booking_id].to_s + " has been requested."
    else
        raise "ERROR: unidentified type of notification in admin mailer"
    end

    # Send
    mail(:to => "justin_leclerc@hotmail.com", :subject => 'Playogo Action')
    
  end
end