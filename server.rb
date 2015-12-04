require 'socket'
require './app'

class Server
  def initialize(port, ip)
    @server = TCPServer.open(ip, port)
    @tracker = FlightTracker.new
    run
  end

  def run
    loop do
      Thread.start(@server.accept) do |client|
        params = []
        response = client.gets.split(' ')

        if response[1].start_with?("/entry")
          flight_id = response[1][/([A-Z])\w+/]
          unless flight_id.nil?
            response = @tracker.logFlight(flight_id)
          else
            puts 'no good'
            raise ArgumentError.new("The is not a compatible flight")
          end

        elsif response[1].start_with?("/tracking")
          response = @tracker.getFlights
        else
          response = 'You have successfully reached the Flight Tracker API but that is not an acceptable route.'
        end

        unless response.nil?
          client.print "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Content-Length: #{response.bytesize}\r\n" +
               "Access-Control-Allow-Origin: *\r\n" +
               "Connection: close\r\n"

          client.print "\r\n"

          client.print response
        end

        client.close
      end
    end
  end
end


Server.new(3000, "localhost")
