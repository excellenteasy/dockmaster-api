'use strict'

# START Dependencies
restify = require 'restify'
http = require 'http'
preflighter = require 'se7ensky-restify-preflight'
api = require './api'
# END Dependencies

server = restify.createServer
  name: 'DockMaster REST API'
  version: '0.0.0'

# add preflight (OPTIONS) support via 'se7ensky-restify-preflight'
preflighter server

server.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
  res.header 'Access-Control-Allow-Methods', 'POST, GET, PUT, DELETE, OPTIONS'
  next()

server.get '/workorders', (req, res, next) ->
  body = JSON.stringify {"LastUpdateDate":"","LastUpdateTime":""}
  extReq = http.request
    hostname: 'api.dockmaster.com'
    port: 3100
    path: '/DB2Web.asmx/RetrieveWorkOrdersJSON'
    method: 'POST'
    headers:
      'content-type': 'application/json'
      'content-length': body.length+''
      'connection': 'keep-alive'
      'accept': '*/*'
  , (extRes) ->
    responseData = ''
    console.log 'STATUS: ' + extRes.statusCode
    console.log 'HEADERS: ' + JSON.stringify(extRes.headers)
    extRes.setEncoding 'utf8'
    extRes.on 'error', (e) ->
      console.log "ERROR: #{e.message}"
    extRes.on 'data', (chunk) ->
      console.log "CHUNK: #{chunk}"
      responseData += chunk
    extRes.on 'end', ->
      responseData = api.parse responseData
      res.statusCode = 200
      res.end(responseData)

  extReq.on 'error', (e) ->
    console.log "ERROR EXTREQ: #{e.message}"

  extReq.write body
  extReq.end()

server.pre restify.pre.userAgentConnection()

server.listen 1338, ->
  console.log '%s listening at %s', server.name, server.url