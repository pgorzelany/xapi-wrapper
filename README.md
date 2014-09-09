##Overview

Simple async [xAPI 3.0](http://developers.xstore.pro/) wrapper for [Node.js](http://nodejs.org/) written in [Coffeescript](http://coffeescript.org/).

##Prerequisites

Node version 0.10 or higher (testes on Node v0.10.30)

##Instalation

`npm install xapi-wrapper`

##Example wrapper usage

[See Wrapper example](src/wrapper-example.litcoffee)

##Wrapper Docs (Draft)

###Class: Wrapper(server_url, conn_port, stream_port, username, password, [options])

The main Wrapper class. By using it you initialize the client. Example:

    Wrapper = new Wrapper(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

You can then use the Wrapper methods and properties to interact with xapi.

Options should be an object. Example

    Options =
      autoReconnect: true

###Wrapper.connect()

Connects to the specified server and conn port

###Wrapper.disconnect()

Disconnects from the server

###Wrapper.on(event, callback)

Registeres a callback for an event. For events generated on responses to commands, the callback should take 3 arguments ([error], request, response)

List of events:

- open

- error

- close

- apiError

- login

- logout

- addOrder

- closePosition

- deletePending

- getAccountIndicators

- getAccountInfo

- getAllSymbols

...

###Wrapper.login([args], [customTag])

Logs user to the xapi server

###Wrapper.logout([customTag])

Logs out of the server

###Wrapper.addOrder(args, [customTag])

Sends an order with the specified [arguments](http://developers.xstore.pro/documentation#addOrder).

###Wrapper.connectStream()

Connects to the streaming port

###Wrapper.disconnectStream()

Disconnects from the streaming port

###Wrapper.server_url

Returns the instance server url

###Wrapper.conn_port

Returns the insance port for the normal socket connection

###Wrapper.stream_port

Returns the instance port for the stream connection

###Wrapper.username

Returns the instance username. Username is used to login to xapi

###Wrapper.password

Returns the instance password. Password is used to login to xapi

###Wrapper.conn_status

Returns the current status of the connection

###Wrapper.stream_status

Returns the current status of the stream
