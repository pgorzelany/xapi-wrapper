Connector = require('xapi-connector')
Emitter = require('events').EventEmitter

class Wrapper
  constructor: (@server_url, @conn_port, @stream_port, @username, @password) ->
    @conn_status = 0
    @stream_status = 0
    @_req_id = 0
    @_stream_session_id = null
    @_requests = {}
    @_emitter = new Emitter()
    @_streamEmitter = new Emitter()
    @_connector = new Connector(@server_url, @conn_port, @stream_port, @username, @password)

    @_connector.on('open', () =>
      @conn_status = 1
      @_emitter.emit('open')
      )

    @_connector.on('close', () =>
      @conn_status = 2
      @_emitter.emit('close')
      )

    @_connector.on('error', () =>
      @conn_status = 3
      @_emitter.emit('error')
      )

    @_connector.on('message', (msg) =>
      console.log("Received a msg #{msg}")
      try
        res = JSON.parse(msg)
        if res.status == true
          req_id = res.custommTag
          req = @_requests[req_id]
          if req.customTag? then res.customTag = req.customTag else delete res.customTag
          @_emitter.emit(req_id, null, req, res) #emits the req_id, this enables callbacks for individual requests
          @_emitter.emit(req.command, null, req, res) #emits the command name, this enables event handlers for commands
          @_emitter.emit('_message', JSON.stringify(res)) #emits response with original customTag, this enables middleware
        else
          @_emitter.emit('apiError', req, res)
      catch e
        console.log(e)
      )

    @on('login', (err, req, res) ->
      @_stream_session_id = res.streamSessionId
      )

  on: (event, callback) ->
    @_emitter.on(event, callback)

  _send: (command, args, custom_tag, callback) ->
    req_id = @_req_id += 1
    if callback? then @_emitter.on(req_id, callback)
    @_requests.req_id =
      command: command,
      arguments: args if args?
      customTag: custom_tag if custom_tag?
    req = @_connector.buildCommand(command, args, req_id)
    console.log("Sending message #{req}")
    @_connector.send(req)

  login: (custom_tag, callback) ->
    @_send('login', {userId: @username, password: @password}, custom_tag)

  logout: (custom_tag, callback) ->
    @_send('logout', null, custom_tag)

  ping: (custom_tag, callback) ->
    @_send('ping', null, custom_tag)

  connect: () ->
    @_connector.connect()

  disconnect: () ->
    @_connector.disconnect()


module.exports = Wrapper
