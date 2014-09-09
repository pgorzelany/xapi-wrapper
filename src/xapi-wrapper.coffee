Connector = require('xapi-connector')
Emitter = require('events').EventEmitter

print = (msg) -> console.log(msg)

class Wrapper
  constructor: (@server_url, @conn_port, @stream_port, @username, @password) ->
    @conn_status = 0
    @stream_status = 0
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
      #console.log("Received a msg #{msg}")
      try
        res = JSON.parse(msg)
        req_id = parseInt(res.customTag)
        req = @_requests[req_id]
        if req.customTag? then res.customTag = req.customTag else delete res.customTag
        if res.status == true
          #print("req_id: #{req_id}, requests: #{JSON.stringify(@_requests)}")
          #@_emitter.emit(req_id, null, req, res) #emits the req_id, this enables callbacks for individual requests
          @_emitter.emit(req.command, req, res) #emits the command name, this enables event handlers for commands
          @_emitter.emit('_message', JSON.stringify(res)) #emits a private _message event and passes every message, this enables middleware
        else
          @_emitter.emit('apiError', req, res)
      catch e
        console.log(e)
      )

    @_connector.onStream('message', (msg) =>
      try
        msg = JSON.parse(msg)
        @_streamEmitter(msg.command, msg)
      catch e
        console.log(e)
      )

    @_connector.onStream('open', () ->
      @stream_status = 1
      @_streamEmitter.emit('open')
      )

    @_connector.onStream('close', () ->
      @stream_status = 2
      @_streamEmitter.emit('close')
      )

    @_connector.onStream('error', () ->
      @stream_status = 3
      @_streamEmitter.emit('error')
      )

    @on('login', (req, res) ->
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

  connect: () ->
    @_connector.connect()

  disconnect: () ->
    @_connector.disconnect()

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
    @_send('getAccountIndicators', custom_tag)

  getAccountInfo: (args, custom_tag) ->
    @_send('getAccountInfo', args, custom_tag)

  getAllSymbols: (args, custom_tag) ->
    @_send('getAllSymbols', args, custom_tag)

  getCalendar: (args, custom_tag) ->
    @_send('getCalendar', args, custom_tag)

  getCandles: (args, custom_tag) ->
    @_send('getCandles', args, custom_tag)

  getCashOperationsHistory: (args) ->
    @_send('getCashOperationsHistory', args, custom_tag)

  getCommisionsDef: (args) ->
    @_send('getCommisionsDef', args, custom_tag)

  getlbsHistory: (args) ->
    @_send('getlbsHistory', args, custom_tag)

  getMarginTrade: (args) ->
    @_send('getMarginTrade', args, custom_tag)

  getNews: (args) ->
    @_send('getNews', args, custom_tag)

  getOrderStatus: (args) ->
    @_send('getOrderStatus', args, custom_tag)

  getProfitCalculations: (args) ->
    @_send('getProfitCalculations', args, custom_tag)

  getServerTime: (args) ->
    @_send('getServerTime', args, custom_tag)

  getStepRules: (args) ->
    @_send('getStepRules', args, custom_tag)

  getSymbol: (args) ->
    @_send('getSymbol', args, custom_tag)

  getTickPrices: (args) ->
    @_send('getTickPrices', args, custom_tag)

  getTradeRecords: (args) ->
    @_send('getTradeRecords', args, custom_tag)

  getTrades: (args) ->
    @_send('getTrades', args, custom_tag)

  getTradesHistory: (args) ->
    @_send('getTradesHistory', args, custom_tag)

  getTradingHours: (args) ->
    @_send('getTradingHours', args, custom_tag)

  getVersion: (args) ->
    @_send('getVersion', args, custom_tag)

  modifyPending: (args) ->
    @_send('modifyPending', args, custom_tag)

  modifyPosition: (args) ->
    @_send('modifyPosition', args, custom_tag)


  subscribeAccountIndicators: (stream_session_id) ->
    @_connector.sendStream(@_connector.buildStreamCommand('getAccountIndicators', @_stream_session_id))

  subscribeCandles: (stream_session_id) ->
    @_connector.sendStream(@_connector.buildStreamCommand('getCandles', @_stream_session_id))

  subscribeKeepAlive: (stream_session_id) ->
    @_connector.sendStream(@_connector.buildStreamCommand('getKeepAlive', @_stream_session_id))

  subscribeNews: (stream_session_id) ->
    @_connector.sendStream(@_connector.buildStreamCommand('getNews', @_stream_session_id))

  subscribeOrderStatus: (stream_session_id) ->
    @_connector.sendStream(@_connector.buildStreamCommand('getOrderStatus', @_stream_session_id))

  subscribeProfits: (stream_session_id) ->
    @_connector.sendStream(@_connector.buildStreamCommand('getProfits', @_stream_session_id))

  subscribeTickPrices: (stream_session_id, symbols) ->
    @_connector.sendStream(@_connector.buildStreamCommand('getTickPrices', @_stream_session_id, symbols))

  subscribeTrades: (stream_session_id) ->
    @_connector.sendStream(@_connector.buildStreamCommand('getTrades', @_stream_session_id))


module.exports = Wrapper
