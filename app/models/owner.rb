class Owner < ActiveRecord::Base
  has_many :venues, :dependent => :destroy

  # Several database schema need to be added including owner information.
  # This is a temporary way of accessing policies before deciding how to store it
  def hardCodedPolicies()
    return ["Rescheduling an ice time must be done at least 3 business days before the scheduled date.",
            "Ice bookings are non-refundable."]
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
