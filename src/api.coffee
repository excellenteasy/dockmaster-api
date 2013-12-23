'use strict'

# START Dependencies
express = require 'express'
dockMaster = require '../lib/dockMaster'
_ = require 'lodash'
endpoints = require '../lib/endpointsConfig'
FormUrlEncode = require 'form-urlencoded'
# END Dependencies

# Prevent server from going down by unexpected errors
process.on 'uncaughtException', (err) ->
  console.log '>>> uncaught exception !', err
  console.log err.stack

app = express()
app.set 'name', 'DockMaster REST API'
app.set 'version', '0.0.0'

app.use express.logger()
app.use express.json()
app.use express.urlencoded()

app.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  headers = 'X-Requested-With, content-type, Content-Type'
  res.header 'Access-Control-Allow-Headers', headers
  res.header 'Access-Control-Allow-Methods', 'POST, GET, PUT, DELETE, OPTIONS'
  next()

# Define routes from endpoints config
for route, conf of endpoints.routes
  _.keys(conf).forEach (method) ->
    method = method.toLowerCase()
    app[method] route, dockMaster.config, dockMaster.request

# UpdateLeadRequest | POST /prospects
postNewLead = (req, res, next) ->
  params = if _.isString req.body then JSON.parse req.body else req.body

  if _.isObject params
    params = webprospects: [webprospect: params]
  else if _.isArray params
    params = (webprospect: param for param in params)
    params = webprospects: params
  else
    return console.error 'request body is malformed'
  params = FormUrlEncode.encode LeadJSON: JSON.stringify params

  headers = _.cloneDeep(_.merge req.param('headers') or
    endpoints.defaults.headers)
  headers['content-type'] = 'application/x-www-form-urlencoded'

  res.locals.config =
    hostname: req.param('hostname') or endpoints.defaults.hostname
    soapMethod: 'UpdateLeadRequest'
    httpMethod: 'POST'
    port: req.param('port') or endpoints.defaults.port
    params: params
    headers: headers

  next()

app.post '/prospects', postNewLead, dockMaster.postNewLead

# SubmitTimeEntry | POST /timeEntries
postNewTimeEntry = (req, res, next) ->
  params = if _.isString req.body then JSON.parse req.body else req.body

  if not _.isObject params
    return console.error 'request body is malformed'
  params = FormUrlEncode.encode RequestJSON: JSON.stringify params

  headers = _.cloneDeep(_.merge req.param('headers') or
    endpoints.defaults.headers)
  headers['content-type'] = 'application/x-www-form-urlencoded'

  res.locals.config =
    hostname: req.param('hostname') or endpoints.defaults.hostname
    soapMethod: 'SubmitTimeEntry'
    httpMethod: 'POST'
    port: req.param('port') or endpoints.defaults.port
    params: params
    headers: headers

  next()

app.post(
  '/workorders/:id/operations/:opcode/timeEntries',
  postNewTimeEntry,
  dockMaster.postNewLead)

app.listen (port = process.env.PORT or 1338), require('os').hostname(), ->
  console.log '%s listening at %s', app.get('name'), port
