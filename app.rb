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
        t.datetime :entry_time
        t.datetime :final_start
        t.string :status

        t.timestamps null: false
      end
    end
  end
end

class Flight < ActiveRecord::Base
  validates :flight_number, presence: true
  validates :speed, presence: true
  validates :entry_time, presence: true
  validates :final_start, presence: true
  validates :status, presence: true
end

CreateFlights.new.change


class FlightTracker
  STANDARD_LENGTH = 65291
  FINAL_LENGTH = 15021
  FINAL_SPEED = 70
  MIN_DISTANCE = 5200


  def computeSpeed(time)
    prev_flight = Flight.where(status: 'descent').last
    unless prev_flight.nil?
      ideal_speed = (STANDARD_LENGTH - MIN_DISTANCE) / (prev_flight.final_start - time)
      speed = ideal_speed > 128 ? 128 : ideal_speed
    else
      speed = 128
    end

    if speed < 120
      return [128, 0, 'diverted']
    else
      final_approach_time = Time.now + (65291 / speed).seconds
      return [speed, final_approach_time, 'descent']
    end
  end

  def computeLocation(flight)
    flight_info = {flight: flight.flight_number, x: 4200, y: 23004, altitude: 8000, status: flight.status}
    flight_info
  end

  def logFlight(flight_number)
    enter_at = Time.now
    flight_data = computeSpeed(enter_at)
    Flight.create(flight_number: flight_number, speed: flight_data[0], entry_time: enter_at, final_start: flight_data[1], status: flight_data[2] )
    puts flight_number + ' created.'
  end

  def getFlights
    flights_data = []
    flights = Flight.where(created_at: (Time.now - 3.minutes)..(Time.now))
    flights.each {|flight| flights_data << computeLocation(flight)}
    flights_json = {aircrafts: flights_data}
    flights_json.to_json
  end

end
