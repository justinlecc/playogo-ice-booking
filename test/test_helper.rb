ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def drop_all
    Owner.delete_all
    Venue.delete_all
    Theatre.delete_all
    Opening.delete_all
    Booking.delete_all
    Price.delete_all
  end

  def drop_and_load_fixtures



    return true
  end
  # Add more helper methods to be used by all tests here...
end
