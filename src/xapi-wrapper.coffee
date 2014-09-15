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
      print("CONNECTION CLOSED")
      @_emitter.emit('close')
      )

    @_connector.on('error', (err) =>
      @conn_status = 3
      print("CONNECTION ERROR")
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
      print("STREAM CLOSED")
      @_streamEmitter.emit('close')
      )

    @_connector.onStream('error', (err) =>
      @stream_status = 3
      print("STREAM ERROR")
      @_streamEmitter.emit('error', err)
      )

    @on('login', (req, res) =>
      @_stream_session_id = res.streamSessionId
      )

  on: (event, callback) ->
    @_emitter.on(event, callback)
    return

  onStream: (event, callback) ->
    @_streamEmitter.on(event, callback)
    return

  #EXPERIMENTAL
  use: (plugin) ->
    plugin(@)
    return

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
    return

  _sendStream: (msg) ->
    #print(msg)
    @_connector.sendStream(msg)
    return

  connect: () ->
    @_connector.connect()
    return

  disconnect: () ->
    @_connector.disconnect()
    return

  connectStream: () ->
    @_connector.connectStream()
    return

  disconnectStream: () ->
    @_connector.disconnectStream()
    return

  login: (custom_tag) ->
    @_send('login', {userId: @username, password: @password}, custom_tag)
    return

  logout: (custom_tag) ->
    @_send('logout', null, custom_tag)
    return

  ping: (custom_tag) ->
    @_send('ping', null, custom_tag)
    return

  addOrder: (args, custom_tag) ->
    @_send('addOrder', args, custom_tag)
    return

  closePosition: (args, custom_tag) ->
    @_send('closePosition', args, custom_tag)
    return

  closePositions: (args, custom_tag) ->
    @_send('closePositions', args, custom_tag)
    return

  deletePending: (args, custom_tag) ->
    @_send('deletePending', args, custom_tag)
    return

  getAccountIndicators: (custom_tag) ->
    @_send('getAccountIndicators', null, custom_tag)
    return

  getAccountInfo: (custom_tag) ->
    @_send('getAccountInfo', null, custom_tag)
    return

  getAllSymbols: (custom_tag) ->
    @_send('getAllSymbols', null, custom_tag)
    return

  getCalendar: (custom_tag) ->
    @_send('getCalendar', null, custom_tag)
    return

  getCandles: (args, custom_tag) ->
    @_send('getCandles', args, custom_tag)
    return

  getCashOperationsHistory: (args, custom_tag) ->
    @_send('getCashOperationsHistory', args, custom_tag)
    return

  getCommisionsDef: (args, custom_tag) ->
    @_send('getCommisionsDef', args, custom_tag)
    return

  getlbsHistory: (args, custom_tag) ->
    @_send('getlbsHistory', args, custom_tag)
    return

  getMarginTrade: (args, custom_tag) ->
    @_send('getMarginTrade', args, custom_tag)
    return

  getNews: (args, custom_tag) ->
    @_send('getNews', args, custom_tag)
    return

  getOrderStatus: (args, custom_tag) ->
    @_send('getOrderStatus', args, custom_tag)
    return

  getProfitCalculations: (args, custom_tag) ->
    @_send('getProfitCalculations', args, custom_tag)
    return

  getServerTime: (args, custom_tag) ->
    @_send('getServerTime', args, custom_tag)
    return

  getStepRules: (custom_tag) ->
    @_send('getStepRules', null, custom_tag)
    return

  getSymbol: (args, custom_tag) ->
    @_send('getSymbol', args, custom_tag)
    return

  getTickPrices: (args, custom_tag) ->
    @_send('getTickPrices', args, custom_tag)
    return

  getTradeRecords: (args, custom_tag) ->
    @_send('getTradeRecords', args, custom_tag)
    return

  getTrades: (custom_tag) ->
    @_send('getTrades', null, custom_tag)
    return

  getTradesHistory: (args, custom_tag) ->
    @_send('getTradesHistory', args, custom_tag)
    return

  getTradingHours: (args, custom_tag) ->
    @_send('getTradingHours', args, custom_tag)
    return

  getVersion: (custom_tag) ->
    @_send('getVersion', null, custom_tag)
    return

  modifyPending: (args, custom_tag) ->
    @_send('modifyPending', args, custom_tag)
    return

  modifyPosition: (args, custom_tag) ->
    @_send('modifyPosition', args, custom_tag)
    return


  subscribeAccountIndicators: () ->
    @_sendStream(@_connector.buildStreamCommand('getAccountIndicators', @_stream_session_id))
    return

  subscribeCandles: (args) ->
    @_sendStream(@_connector.buildStreamCommand('getCandles', @_stream_session_id, args))
    return

  subscribeKeepAlive: () ->
    @_sendStream(@_connector.buildStreamCommand('getKeepAlive', @_stream_session_id))
    return

  subscribeNews: () ->
    @_sendStream(@_connector.buildStreamCommand('getNews', @_stream_session_id))
    return

  subscribeOrderStatus: () ->
    @_sendStream(@_connector.buildStreamCommand('getOrderStatus', @_stream_session_id))
    return

  subscribeProfits: () ->
    @_sendStream(@_connector.buildStreamCommand('getProfits', @_stream_session_id))
    return

  subscribeTickPrices: (args) ->
    @_sendStream(@_connector.buildStreamCommand('getTickPrices', @_stream_session_id, args))
    return

  subscribeTrades: () ->
    @_sendStream(@_connector.buildStreamCommand('getTrades', @_stream_session_id))
    return

  unsubscribeAccountIndicators: () ->
    @_sendStream(@_connector.buildStreamCommand('stopAccountIndicators'))
    return

  unsubscribeCandles: (args) ->
    @_sendStream(@_connector.buildStreamCommand('stopCandles', args))
    return

  unsubscribeKeepAlive: () ->
    @_sendStream(@_connector.buildStreamCommand('stopKeepAlive'))
    return

  unsubscribeNews: () ->
    @_sendStream(@_connector.buildStreamCommand('stopNews'))
    return

  unsubscribeOrderStatus: () ->
    @_sendStream(@_connector.buildStreamCommand('stopOrderStatus'))
    return

  unsubscribeProfits: () ->
    @_sendStream(@_connector.buildStreamCommand('stopProfits'))
    return

  unsubscribeTickPrices: (args) ->
    @_sendStream(@_connector.buildStreamCommand('stopTickPrices', args))
    return

  unsubscribeTrades: () ->
    @_sendStream(@_connector.buildStreamCommand('stopTrades'))
    return


module.exports = Wrapper
