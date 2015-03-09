require 'test_helper'

class PriceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Simple data insert and check" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})

    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})

    # Price
    @price1 = Price.create!({:prime => 20000, :non_prime => 13333, :insurance => 444, :theatre => @theatre1})

    assert @venue1.valid? && @theatre1.valid? && @price1.valid?
  end
  test "check prices and insurance" do
    drop_all
    # Venues
    @venue1 = Venue.create!({:name => "venue1"})

    # Theatres
    @theatre1 = Theatre.create!({:name => "theatre1", :venue => @venue1})

    # Price
    @price1 = Price.create!({:prime => 20000, :non_prime => 13333, :insurance => 444, :theatre => @theatre1})

    assert @venue1.valid? && @theatre1.valid? && @price1.valid?

    assert @theatre1.price.prime == 20000
    assert @venue1.theatres[0].price.insurance == 444
    assert @price1.theatre.venue.name == "venue1"
  end
end
