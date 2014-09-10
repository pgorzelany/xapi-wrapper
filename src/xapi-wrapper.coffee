Connector = require('xapi-connector')
Emitter = require('events').EventEmitter

print = (msg) -> console.log(msg)

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

    @_connector.on('error', (err) =>
      @conn_status = 3
      @_emitter.emit('error', err)
      )

    @_connector.on('message', (msg) =>
      #console.log("Received a msg #{msg}")
      try
        res = JSON.parse(msg)
        req_id = parseInt(res.customTag)
        req = @_requests[req_id]
        if req.customTag? then res.customTag = req.customTag else delete res.customTag
        if res.status == true
          #print("req_id: #{req_id}, requests: #{JSON.stringify(@_requests)}")
          #@_emitter.emit(req_id, null, req, res) #emits the req_id, this enables callbacks for individual requests
          @_emitter.emit('_message', req, res, @) #emits a private _message event and passes every message, this enables plugins
          @_emitter.emit(req.command, req, res, @) #emits the command name, this enables event handlers for commands
        else
          @_emitter.emit('apiError', req, res)
      catch e
        console.log(e)
      )

    @_connector.onStream('message', (msg) =>
      #console.log("Received a stream msg #{msg}")
      try
        msg = JSON.parse(msg)
        @_streamEmitter.emit('_message', msg, @) #enables plugins for stream
        @_streamEmitter.emit(msg.command, msg, @)
      catch e
        console.log(e)
      )

    @_connector.onStream('open', () =>
      @stream_status = 1
      @_streamEmitter.emit('open')
      )

    @_connector.onStream('close', () =>
      @stream_status = 2
      @_streamEmitter.emit('close')
      )

    @_connector.onStream('error', (err) =>
      @stream_status = 3
      @_streamEmitter.emit('error', err)
      )

    @on('login', (req, res) =>
      @_stream_session_id = res.streamSessionId
      )

    @on('apiError', (req, res) ->
      if req.command == 'login' and res.redirect?
        print("Server response to login: #{res}")
        @disconnect()
        @server_url = res.redirect.address
        @conn_port = res.redirect.mainPort
        @stream_port = res.redirect.streamingPort
        print("Redirecting to server: #{@server_url}, port: #{@conn_port}, stream port: #{stream_port}")
        @connect()
      )

  on: (event, callback) ->
    @_emitter.on(event, callback)

  onStream: (event, callback) ->
    @_streamEmitter.on(event, callback)

  #EXPERIMENTAL
  use: (event, callback) ->
    if arguments.length == 2
      @on(event, callback)
    else
      @on('_message', callback)

  #EXPERIMENTAL
  useStream: (callback) ->
    if arguments.length == 2
      @onStream(event, callback)
    else
      @onStream('_message', callback)

  getQue: () -> @_connector.getQue()

  getStreamQue: () -> @_connector.getStreamQue()

  _send: (command, args, custom_tag) ->
    req_id = @_req_id += 1
    #if callback? then @.on(req_id, callback)
    @_requests[req_id] =
      command: command,
      arguments: args if args?
      customTag: custom_tag if custom_tag?
    req = @_connector.buildCommand(command, args, req_id.toString())
    #console.log("Sending message #{req}")
    @_connector.send(req)

  _sendStream: (msg) ->
    #print(msg)
    @_connector.sendStream(msg)

  connect: () ->
    @_connector.connect()

  disconnect: () ->
    @_connector.disconnect()

  connectStream: () ->
    @_connector.connectStream()

  disconnectStream: () ->
    @_connector.disconnectStream()

  login: (custom_tag) ->
    @_send('login', {userId: @username, password: @password}, custom_tag)

  logout: (custom_tag) ->
    @_send('logout', null, custom_tag)

  ping: (custom_tag) ->
    @_send('ping', null, custom_tag)

  addOrder: (args, custom_tag) ->
    @_send('addOrder', args, custom_tag)

  closePosition: (args, custom_tag) ->
    @_send('closePosition', args, custom_tag)

  closePositions: (args, custom_tag) ->
    @_send('closePositions', args, custom_tag)

  deletePending: (args, custom_tag) ->
    @_send('deletePending', args, custom_tag)

  getAccountIndicators: (custom_tag) ->
    @_send('getAccountIndicators', null, custom_tag)

  getAccountInfo: (custom_tag) ->
    @_send('getAccountInfo', null, custom_tag)

  getAllSymbols: (custom_tag) ->
    @_send('getAllSymbols', null, custom_tag)

  getCalendar: (custom_tag) ->
    @_send('getCalendar', null, custom_tag)

  getCandles: (args, custom_tag) ->
    @_send('getCandles', args, custom_tag)

  getCashOperationsHistory: (args, custom_tag) ->
    @_send('getCashOperationsHistory', args, custom_tag)

  getCommisionsDef: (args, custom_tag) ->
    @_send('getCommisionsDef', args, custom_tag)

  getlbsHistory: (args, custom_tag) ->
    @_send('getlbsHistory', args, custom_tag)

  getMarginTrade: (args, custom_tag) ->
    @_send('getMarginTrade', args, custom_tag)

  getNews: (args, custom_tag) ->
    @_send('getNews', args, custom_tag)

  getOrderStatus: (args, custom_tag) ->
    @_send('getOrderStatus', args, custom_tag)

  getProfitCalculations: (args, custom_tag) ->
    @_send('getProfitCalculations', args, custom_tag)

  getServerTime: (args, custom_tag) ->
    @_send('getServerTime', args, custom_tag)

  getStepRules: (custom_tag) ->
    @_send('getStepRules', null, custom_tag)

  getSymbol: (args, custom_tag) ->
    @_send('getSymbol', args, custom_tag)

  getTickPrices: (args, custom_tag) ->
    @_send('getTickPrices', args, custom_tag)

  getTradeRecords: (args, custom_tag) ->
    @_send('getTradeRecords', args, custom_tag)

  getTrades: (custom_tag) ->
    @_send('getTrades', null, custom_tag)

  getTradesHistory: (args, custom_tag) ->
    @_send('getTradesHistory', args, custom_tag)

  getTradingHours: (args, custom_tag) ->
    @_send('getTradingHours', args, custom_tag)

  getVersion: (custom_tag) ->
    @_send('getVersion', null, custom_tag)

  modifyPending: (args, custom_tag) ->
    @_send('modifyPending', args, custom_tag)

  modifyPosition: (args, custom_tag) ->
    @_send('modifyPosition', args, custom_tag)


  subscribeAccountIndicators: () ->
    @_sendStream(@_connector.buildStreamCommand('getAccountIndicators', @_stream_session_id))

  subscribeCandles: () ->
    @_sendStream(@_connector.buildStreamCommand('getCandles', @_stream_session_id))

  subscribeKeepAlive: () ->
    @_sendStream(@_connector.buildStreamCommand('getKeepAlive', @_stream_session_id))

  subscribeNews: () ->
    @_sendStream(@_connector.buildStreamCommand('getNews', @_stream_session_id))

  subscribeOrderStatus: () ->
    @_sendStream(@_connector.buildStreamCommand('getOrderStatus', @_stream_session_id))

  subscribeProfits: () ->
    @_sendStream(@_connector.buildStreamCommand('getProfits', @_stream_session_id))

  subscribeTickPrices: (symbols) ->
    @_sendStream(@_connector.buildStreamCommand('getTickPrices', @_stream_session_id, symbols))

  subscribeTrades: () ->
    @_sendStream(@_connector.buildStreamCommand('getTrades', @_stream_session_id))


module.exports = Wrapper
