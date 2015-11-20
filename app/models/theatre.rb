class Theatre < ActiveRecord::Base
  belongs_to :venue
  has_many :openings
  has_many :bookings
  has_one :price

  def getPrice(date, startTime, length)
    primeStart      = 17 * 3600 # TODO: should be stored in Price model
    tax             = 0.13     # TODO: should be stored in Price model
    pricing         = self.price
    dayOfWeek       = Date.strptime(date, "%Y-%m-%d")
    primeSeconds    = 0
    nonPrimeSeconds = 0

    # All prime
    if (dayOfWeek == 0 || dayOfWeek == 6 || startTime >= primeStart)
      primeSeconds = length

    # All non prime
    elsif (startTime + length < primeStart)
      nonPrimeSeconds = length

    # Mixture of prime and non prime
    else
      primeSeconds = length - (primeStart - startTime)
      nonPrimeSeconds = primeStart - startTime
    end

    primeHours    = (primeSeconds * 1.00000) / 3600
    nonPrimeHours = (nonPrimeSeconds * 1.00000) / 3600

    puts "prime hours:     " + primeHours.to_s
    puts "non prime hours: " + nonPrimeHours.to_s

    cost = (primeHours * pricing.prime) + (nonPrimeHours * pricing.non_prime) + pricing.insurance

    return ((cost + (cost * tax)) * 100).round / 100
  end
end
