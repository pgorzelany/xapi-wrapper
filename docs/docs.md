###Class: Wrapper(server_url, conn_port, stream_port, username, password, [options])

The main Wrapper class. By using it you initialize the client. Example:

    Wrapper = new Wrapper(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

You can then use the Wrapper methods and properties to interact with xapi.

Options should be an object.

###Wrapper.connect()

Connects to the specified server and conn port

###Wrapper.disconnect()

Disconnects from the server

###Wrapper.on(event, callback)

Registeres a callback for an event. For events generated on responses to commands, the callback should take 2 arguments (request, response).
For commands like login, logout etc. the event name is the same as the command name in xAPI specification.

List of events:

- open: Emitted on connection open

- error: Emitted on connection close

- close: Emitted on connection error

- apiError:  Emitted when the response status for a command is equal to false

- login: Emitted on login

- logout: Emitted on logout

- addOrder: Emitted on response to addOrder command

- closePosition: Emitted on response to closePosition command

- deletePending: Emitted on response to deletePending command

- getAccountIndicators: Emitted on response to getAccountIndicators command

- getAccountInfo: Emitted on response to getAccountInfo command

- getAllSymbols: Emitted on response to getAllSymbols command

...

###Wrapper.use(plugin)

This method enables external plugins. The plugin is simply a function that should receive 1 parameter (client).
The plugin function can internally make use of the client (wrapper) methods. For example it can register callbacks for client events.

    plugins = require("xapi-plugins")
    autoRedirect = plugins.autoRedirect

    wrapper = new Wrapper(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)
    wrapper.use(autoRedirect)

WARNING: The pugin can alter the way the client works, use with caution (experimental feature)!

###Wrapper.login([customTag])

Logs user to the xapi server

###Wrapper.logout([customTag])

Logs out of the server

###Wrapper.addOrder(args, [customTag])

Sends an order with the specified [arguments](http://developers.xstore.pro/documentation#addOrder).

...

###Wrapper.connectStream()

Connects to the streaming port

###Wrapper.disconnectStream()

Disconnects from the streaming port

###Wrapper.subscribeAccountIndicators()

Subscribes to stream Account Indicators

....

###Wrapper.getQue()

Returns the current que of messages to be sent

###Wrapper.getStreamQue()

Returns the current stream que of messages to be sent

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

Returns the current status of the connection:
- 0: Not connected
- 1: Connected
- 2: Closed
- 3: Error

###Wrapper.stream_status

Returns the current status of the stream
- 0: Not connected
- 1: Connected
- 2: Closed
- 3: Error
