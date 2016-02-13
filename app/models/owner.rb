class Owner < ActiveRecord::Base
  has_many :venues, :dependent => :destroy

  # Several database schema need to be added including owner information.
  # This is a temporary way of accessing policies before deciding how to store it
  def hardCodedPolicies()

    return ["Ice time rates subject to change.",
            "Booking total is subject to change depending on activity at the discretion of the " + long_name + ".",
            "Ice schedules are subject to change and Playogo does not guarantee that the timeslot is available until it is confirmed by the " + long_name + ".",
            "Once your booking request has been confirmed by the " + long_name + ", the price of the booking will be charged to your credit card.",
            "Your ice contract will be with the " + long_name + ".",
            "Refer to all terms and conditions of your contract with the " + long_name + ".",
            "Playogo is a non-affiliated third party, who simply makes it easier to find available ice time across a number of markets.",
            "There are no additional fees to book ice time through Playogo."
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
