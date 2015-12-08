/*global jQuery:false*/

(function($) {
  'use strict';

  $(document).ready(function(){
    var url;
    if (document.location.hostname === 'localhost') {
      url = 'http://localhost:3000';
    } else {
      url = 'http://52.35.2.247:3000';
    }

    function createFlight() {
      var flightId = Math.random().toString(36).replace(/[^a-z]+/g, '').slice(2, 4).toUpperCase() + Math.random().toString().slice(2, 5);
      $.ajax({
        method: 'GET',
        url: url + '/entry?flight=' + flightId
      })
      .done(function(msg) {
        console.log(msg);
      });
    }
    createFlight();

    function getFlights() {
      $.ajax({
        method: 'GET',
        url: url + '/tracking_info'
      })
      .done(function(data) {
        if (data.length > 0) {
          var alt, xAxis, yAxis;
          var json = $.parseJSON(data);
          $('#positive').empty();
          $('.tabler table tbody').empty();
          $.each(json.aircrafts, function(i, aircraft) {
             xAxis = (aircraft.x / 20000) * 100;
             yAxis = (aircraft.y / 70000) * -100;
             alt = Math.floor(aircraft.altitude);
             if (aircraft.status !== 'diverted') {
               $('#positive').append('<div class="flight" style="left: ' + xAxis + '%; top: ' + yAxis + '%;"><span class="marker"></span><span class="flight_number" style="background-color: rgba(0,0,' + Math.floor((alt / 10000) * 255) + ',0.7);">' + aircraft.flight + ' @' + alt + 'm</span></div>');
             }
             $('.tabler table tbody').append('<tr><td>' + aircraft.flight + '</td><td>' + Math.floor(aircraft.x) + '</td><td>' + Math.floor(aircraft.y) + '</td><td>' + Math.floor(alt) + '</td><td>' + Math.floor(aircraft.speed) + 'm/s</td><td>' + aircraft.status + '</td></tr>');
          });
          $('tr:odd').addClass('odd');
        }
      });
    }
    getFlights();

    (function loopFlight() {
      var rand = Math.floor(Math.random() * (50000 - 30000) + 30000);
      setTimeout(function() {
        createFlight();
        loopFlight();
      }, rand);
    }());

    (function loopData() {
      setTimeout(function() {
        getFlights();
        loopData();
      }, 3000);
    }());

  });

})(jQuery);
