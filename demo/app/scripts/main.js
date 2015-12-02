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
      // console.log(data);
      $('.marketing .col-lg-6').html(data);
    });
  }
  getFlights();

  (function loop_flight() {
    var rand = Math.floor(Math.random() * (45000 - 20000) + 20000);
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
