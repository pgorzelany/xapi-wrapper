##Example wrapper usage

The socket provided by xAPI is not certified but for now lets ignore it

    process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'

Import the wrapper.

    Wrapper = require('../lib/xapi-wrapper.js')

Import plugins

    plugins = require("xapi-plugins")
    autoRedirect = plugins.autoRedirect

Define statics

    SERVER_URL = 'xapia.x-station.eu'
    CONN_PORT = '5144' #provide port
    STREAM_PORT = '5145' #provide stream port
    USERNAME = '201870' #provide a valid username
    PASSWORD = 'rz3smI' #provide a valid password

Helper functions

    print = (msg) ->
      console.log(msg)
      return

Create the wrapper

    wrapper = new Wrapper(SERVER_URL, CONN_PORT, STREAM_PORT, USERNAME, PASSWORD)

As an example, we will use the autoRedirect plugin. It redirects the connection on redirect message from the xAPI

    wrapper.use(autoRedirect)

Add handlers

    wrapper.on('open', () ->
      print('Successfuly connected, login in')
      wrapper.login()
    )

    wrapper.on('login', (req, res) ->
      print("Succesfuly logged in, connecting to stream")
      wrapper.connectStream()
    )

    wrapper.on('logout', (req, res) ->
      print("Successfuly loged out")
      wrapper.disconnectStream()
      wrapper.disconnect()
    )

    wrapper.on('apiError', (req, err) ->
      print("The api returned a negative response to request: #{JSON.stringify(req, null, 4)}")
      print("#{JSON.stringify(err, null, 4)}")
    )

Define handlers for the stream

    wrapper.onStream('open', () ->
      print("Successfuly connected to stream, subscribing to indicators and EURUSD tick prices")
      wrapper.subscribeAccountIndicators()
      wrapper.subscribeTickPrices({symbols: ['EURUSD']})
    )

    wrapper.onStream('indicators', (msg) ->
      print("Received indicator data: #{JSON.stringify(msg, null, 4)}")
    )

    wrapper.onStream('tickPrices', (msg) ->
      print("Received tick prices: #{JSON.stringify(msg, null, 4)}")
    )


Connect to the api

    wrapper.connect()
    setTimeout(() ->
      print('Login out')
      wrapper.logout()
    ,10000)
