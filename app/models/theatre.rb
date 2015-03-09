class Theatre < ActiveRecord::Base
  belongs_to :venue
  has_many :openings
  has_many :bookings
  has_one :price
end
