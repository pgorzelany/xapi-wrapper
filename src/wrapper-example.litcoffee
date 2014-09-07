##Example wrapper usage

The socket provided by xAPI is not certified but for now lets ignore it

    process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'

Import the wrapper.

    Wrapper = require('../lib/xapi-wrapper.js')

Define statics

    SERVER_URL = 'xapia.x-station.eu'
    CONN_PORT = '5144' #provide port
    STREAM_PORT = '5145' #provide stream port
    USERNAME = '177509' #provide a valid username
    PASSWORD = 'ystk7C' #provide a valid password

Helper functions

    print = (msg) ->
      console.log(msg)
      return
