class Owner < ActiveRecord::Base
  has_many :venues, :dependent => :destroy

  # Several database schema need to be added including owner information.
  # This is a temporary way of accessing policies before deciding how to store it
  def hardCodedPolicies()

    return ["Ice schedules are subject to change and Playogo does not guarantee the timeslot until it is confirmed by the " + long_name + ".",
            "Once your booking request has confirmed by the " + long_name + ", the price of the booking will be charged to your credit card.",
            "Your ice contract will be with the " + long_name + ".",
            "Ice bookings are non-refundable.",
            "Rescheduling an ice time must be done at least 3 business days before the scheduled date.",
            "Playogo is a non-affiliated third party who simply makes it easier to find and purchase icetime.",
            "There are no additional fees to book ice through Playogo."
            ]
  end

  def getInfo ()
    return {
      "id"       => id,
      "name"     => name,
      "long_name" => long_name,
      "policies" => hardCodedPolicies()
    }
  end
end
