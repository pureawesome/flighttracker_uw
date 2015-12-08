Final Project for UW Continuing Education Course

The root folder houses the ruby server and controller. Update the information in the login.rb file first. To run locally change server.rb:7 to TCPServer.open('localhost',port)

to install and control the server:
```
bundle install
ruby server_control.rb [start, restart, stop]
```

The demo folder is the front end for hitting the server api and displaying the information.
```
npm install
bower install
gulp serve
```
