class Venue < ActiveRecord::Base
  belongs_to :owner
  has_many :theatres, :dependent => :destroy
end
