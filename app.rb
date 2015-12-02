require 'active_support/all'
require 'active_record'
require 'mysql2'

ActiveRecord::Base.establish_connection(
  adapter: "mysql2",
  database: "flight_tracker",
  host: "127.0.0.1",
  username: "root"
)

class CreateFlights < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.table_exists? :flights
      create_table :flights do |t|
        t.string :flight_number
        t.decimal :speed

        t.timestamps null: false
      end
    end
  end
end

class Flight < ActiveRecord::Base
  validates :flight_number, presence: true
  validates :speed, presence: true
end

CreateFlights.new.change


class FlightTracker

  def computeSpeed
    time = Time.now
    return 126.54
  end

  def computeLocation(flight)
    puts flight
    flight
  end

  def logFlight(flight_number)
    flight_speed = computeSpeed
    Flight.create(flight_number: flight_number, speed: flight_speed )
    puts flight_number + ' created.'
  end

  def getFlights
    flights_data = []
    flights = Flight.where(created_at: (Time.now - 5.minutes)..(Time.now))
    #flights.each {|flight| flights_data << computeLocation(flight)}
    flights.to_json
  end

end
