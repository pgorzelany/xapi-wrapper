##Overview

Simple async [xAPI 3.0](http://developers.xstore.pro/) wrapper for [Node.js](http://nodejs.org/) written in [Coffeescript](http://coffeescript.org/).

##Prerequisites

Node version 0.10 or higher (testes on Node v0.10.30)

##Instalation



##Example wrapper usage

[See Wrapper example](src/wrapper-example.litcoffee)

##Wrapper Docs (Draft)

###Class: Wrapper(server_url, conn_port, stream_port, username, password, [options])

The main Wrapper class. By using it you initialize the client. Example:

    Wrapper = new Wrapper(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

You can then use the Wrapper methods and properties to interact with xapi

###Wrapper.connect()

Connects to the specified server and conn port

###Wrapper.disconnect()

Disconnects from the server

###Wrapper.server_url

Returns the instance server url

###Wrapper.conn_port

Returns the insance port for the normal socket connection

###Wrapper.stream.port

Returns the instance port for the stream connection

###Wrapper.username

Returns the instance username. Username is used to login to xapi

###Wrapper.password

Returns the instance password. Password is used to login to xapi
