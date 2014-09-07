Connector = require('xapi-connector')
Emitter = require('events').EventEmitter

class Wrapper
  constructor: (@server_url, @conn_port, @stream_port, @username, @password) ->
    @conn_status = 0
    @stream_status = 0
    @_req_id = 0
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
      @_emitter.emit('_message', msg)
      )

  on: (event, callback) ->
    @_emitter.on(event, callback)

  _send: (req_obj) ->
    req_id = @_req_id += 1
    @_requests.req_id = req_obj
    command = req_obj.command
    args = req_obj.arguments
    customTag = req_obj.customTag = req_id
    req = @_connector.buildCommand(command, args, customTag)
    @_connector.send(req)

  login: (args, customTag) ->
    req_obj =
      command: 'login',
      arguments: args,
      customTag: customTag
    @_send(req_obj)

  connect: () ->
    @_connector.connect()
