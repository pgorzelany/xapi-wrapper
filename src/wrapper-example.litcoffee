##Example wrapper usage

The socket provided by xAPI is not certified but for now lets ignore it

    process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'

Import the wrapper.

    Wrapper = require('../lib/xapi-wrapper.js')

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

Add handlers

    wrapper.on('open', () ->
      print('Successfuly connected, login in')
      #wrapper.ping()
      wrapper.login('hello login')
      #wrapper.disconnect()
    )

    wrapper.on('close', () ->
      print('Connection closed')
    )

    wrapper.on('error', () ->
      print('Connection error')
    )

    wrapper.on('login', (err, req, res) ->
      print("Received response to command login")
      print("This is the request: #{JSON.stringify(req)} \nThis is the response #{JSON.stringify(res)}")
      wrapper.ping(null, (err, req, res) ->
        print("Piiiing")
      )
      print("login out")
      wrapper.logout(null, (err, req, res) ->
        print("This is a direct callback for this particular logout request: #{JSON.stringify(req)}. The response is #{JSON.stringify(res)}")
        wrapper.disconnect()
      )
    )


Connect to the api

    wrapper.connect()
