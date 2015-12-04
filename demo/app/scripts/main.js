$(document).ready(function(){

  function createFlight() {
    flight_id = Math.random().toString(36).replace(/[^a-z]+/g,'').slice(2, 4).toUpperCase() + Math.random().toString().slice(2,5);
    $.ajax({
      method: 'GET',
      url: "http://localhost:3000/entry?flight=" + flight_id
    })
    .done(function(msg) {
      console.log('saved ' + msg);
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
        $.each(json.aircrafts, function(i, aircraft) {
           x_axis = (aircraft.x / 20000) * 100;
           y_axis = (aircraft.y / 70000) * -100;
           alt = Math.floor(aircraft.altitude);
           $("#positive").append('<div style="position:absolute; left: '+x_axis+'%; top: '+y_axis+'%;"> X - ' + aircraft.flight + ' @'+ alt +'m</div>');
        });
      }

      $('.marketing .col-lg-6').html(data);
    });
  }
  getFlights();

  function plotData(data) {

  }

  (function loop_flight() {
    var rand = Math.floor(Math.random() * (45000 - 25000) + 25000);
    console.log(rand);
    setTimeout(function() {
            createFlight();
            loop_flight();
    }, rand);
  }());

  (function loop_data() {
    setTimeout(function() {
      getFlights();
      loop_data();
    }, 5000);
  }());

});
