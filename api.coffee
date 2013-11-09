restify = require 'restify'
http = require 'http'

server = restify.createServer
  name: 'DockMaster REST API'
  version: '0.0.0'

server.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
  next()

server.get '/', (req, res, next) ->
  extReq = http.request
    hostname: 'api.dockmaster.com'
    port: 3100
    path: '/DB2Web.asmx/RetrieveWorkOrdersJSON'
    method: 'POST'
  , (extRes) ->
    console.log 'STATUS: ' + extRes.statusCode
    console.log 'HEADERS: ' + JSON.stringify(extRes.headers)
    extRes.setEncoding 'utf8'
    extRes.on 'data', (data) ->
      res.write data
    extRes.on 'end', ->
      res.statusCode = 200
      res.end()
  extReq.on 'error', (e) ->
    console.log 'problem! '+e.message
  extReq.write '{"LastUpdateDate":"","LastUpdateTime":""}'
  extReq.end()

server.pre restify.pre.userAgentConnection()

server.listen 1338, ->
  console.log '%s listening at %s', server.name, server.url