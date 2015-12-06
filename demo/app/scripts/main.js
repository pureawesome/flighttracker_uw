$(document).ready(function(){

  function createFlight() {
    flight_id = Math.random().toString(36).replace(/[^a-z]+/g,'').slice(2, 4).toUpperCase() + Math.random().toString().slice(2,5);
    $.ajax({
      method: 'GET',
      url: "http://localhost:3000/entry?flight=" + flight_id
    })
    .done(function(msg) {
      console.log(msg);
    });
  }
  createFlight();

  function getFlights() {
    $.ajax({
      method: 'GET',
      url: "http://localhost:3000/tracking_info"
    })
    .done(function(data) {
      if (data.length > 0) {
        json = $.parseJSON(data);
        $('#positive').empty();
        $('.table table tbody').empty();
        $.each(json.aircrafts, function(i, aircraft) {
           x_axis = (aircraft.x / 20000) * 100;
           y_axis = (aircraft.y / 70000) * -100;
           alt = Math.floor(aircraft.altitude);
           $("#positive").append('<div class="flight" style="left: '+x_axis+'%; top: '+y_axis+'%;"><span class="marker"></span><span class="flight_number" style="background-color: rgba(0,0,'+Math.floor((alt/10000)*255)+',0.7);">' + aircraft.flight + ' @'+ alt +'m</span></div>');
           $('.table table tbody').append('<tr><td>'+ aircraft.flight +'</td><td>'+Math.floor(aircraft.x)+'</td><td>'+Math.floor(aircraft.y)+'</td><td>'+Math.floor(alt)+'</td><td>'+aircraft.status+'</td></tr>');
        });
        $('tr:odd').addClass('odd');
      }
    });
  }
  getFlights();

  (function loop_flight() {
    var rand = Math.floor(Math.random() * (45000 - 25000) + 25000);
    setTimeout(function() {
      createFlight();
      loop_flight();
    }, rand);
  }());

  (function loop_data() {
    setTimeout(function() {
      getFlights();
      loop_data();
    }, 3500);
  }());

});
