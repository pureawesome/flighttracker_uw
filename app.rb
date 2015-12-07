require 'active_support/all'
require 'active_record'
require 'mysql2'
require './login'

ActiveRecord::Base.establish_connection(
  adapter: "mysql2",
  database: DATABASE,
  host: HOST,
  username: USERNAME
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
  MIN_DISTANCE = 5200

  STANDARD_LENGTH = 65291
  ENTRY_ALT = 10000

  FINAL_LENGTH = 15021
  FINAL_SPEED = 70
  FINAL_APP_ALT = 800

  STANDARD_LAND_DISTANCE = Math.sqrt(65291**2 - (ENTRY_ALT - FINAL_APP_ALT)**2)  # horizontal length
  DESCENT_SLOPE = (ENTRY_ALT - FINAL_APP_ALT) / STANDARD_LAND_DISTANCE # rise / run

  FINAL_LAND_DISTANCE = Math.sqrt(15021**2 - FINAL_APP_ALT**2) #15000
  FINAL_DESCENT_SLOPE = FINAL_APP_ALT / FINAL_LAND_DISTANCE  #0.053

  def get_x(land_distance)
    ( 2.1e-12 * land_distance**3 ) - ( 4.41e-6 * land_distance**2 ) + ( 0.047 * land_distance ) + 16000
  end

  def get_y(land_distance)
    ( 2.23e-14 * land_distance**4 ) - ( 2e-9 * land_distance**3 ) + ( 1.022e-4 * land_distance**2 ) - ( 5 * land_distance ) + 47000
  end

  def get_altitude(land_distance, overall_land_distance, slope)
    (overall_land_distance - land_distance) * slope + 800
  end

  def computeSpeed(time)
    prev_flight = Flight.where.not(status: 'diverted').last
    unless prev_flight.nil?
      #divert if plane enters too close.
      if ((time - prev_flight.entry_time) * prev_flight.speed) < MIN_DISTANCE
        puts 'too close'
        return [128, 0, 'diverted']
      end

      ideal_speed = (STANDARD_LENGTH - MIN_DISTANCE) / (prev_flight.final_start - time)
      speed = ideal_speed > 128 || ideal_speed < 0 ? 128 : ideal_speed

      #divert if plan has to slow down too much.
      if speed < 105
        puts 'ideal speed too slow'
        return [128, 0, 'diverted']
      end
    else
      speed = 128
    end

    final_approach_time = Time.now + (65291 / speed).seconds
    [speed, final_approach_time, 'descent']
  end

  def computeLocation(flight, call_time)
    if flight.final_start < call_time
       current_data = calculateFinal(flight, call_time)
    else
      current_data = calculateDescent(flight, call_time)
    end
    {flight: flight.flight_number, x: current_data[0], y: current_data[1], altitude: current_data[2], status: flight.status}
  end

  def calculateDiverted(time_elapsed)
    a = (time_elapsed % 360) * (Math::PI / 180)
    x = 6000 + 3500 * Math::cos(a)
    y = 35000 + 25000 * Math::sin(a)
    [x, y]
  end

  def calculateDescent(flight, call_time)
    distance_traveled = flight.speed * (call_time - flight.entry_time)
    land_traveled = distance_traveled / Math.sqrt(DESCENT_SLOPE**2 + 1)
    [get_x(land_traveled), get_y(land_traveled), get_altitude(land_traveled, STANDARD_LAND_DISTANCE, DESCENT_SLOPE)]
  end

  def calculateFinal(flight, call_time)
    # descend 800 ft and slow from flight.speed to FINAL_SPEED
    flight.status = 'landing'

    deceleration = (FINAL_SPEED - flight.speed) / 2 * FINAL_LAND_DISTANCE  #v^2 = u^2 + 2as
    time_elapsed = call_time - flight.final_start
    distance_traveled = flight.speed * time_elapsed + (1/2) * deceleration * time_elapsed
    land_distance = distance_traveled / Math.sqrt(FINAL_DESCENT_SLOPE**2 + 1)

    final_x = 0
    final_y = land_distance
    final_alt = (FINAL_LAND_DISTANCE - land_distance) * FINAL_DESCENT_SLOPE

    if final_alt < 0
      flight.status = 'landed'
      [final_x, FINAL_LAND_DISTANCE, 0]
    else
      [final_x, final_y, final_alt]
    end
  end

  def logFlight(flight_number)
    enter_at = Time.now
    flight_data = computeSpeed(enter_at)
    flight = Flight.create(flight_number: flight_number, speed: flight_data[0], entry_time: enter_at, final_start: flight_data[1], status: flight_data[2] )
    { flight: flight.flight_number, status: flight.status }.to_json
  end

  def getFlights
    @flights_data = []
    @call_time = Time.now
    Flight.where(created_at: (Time.now - 15.minutes)..(@call_time)).each do |flight|

      if flight.status == 'diverted'
        @diverted_info = calculateDiverted(Time.now - flight.created_at)
        @flights_data << {flight: flight.flight_number, x: @diverted_info[0], y: @diverted_info[1], altitude: 10000, status: flight.status}
      else
        @flights_data << computeLocation(flight, @call_time)
      end
    end
    {aircrafts: @flights_data}.to_json
  end

end
