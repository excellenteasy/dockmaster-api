'use strict'

# START Dependencies
express = require 'express'
dockMaster = require '../lib/dockMaster'
_ = require 'lodash'
endpoints = require '../lib/endpointsConfig'
# END Dependencies

# Prevent server from going down by unexpected errors
process.on 'uncaughtException', (err) ->
  console.log '>>> uncaught exception !', err
  console.log err.stack
  process.exit 1

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

postNewLead = (req, res, next) ->

  res.locals.config =
    hostname: req.param('hostname') or endpoints.defaults.hostname
    soapMethod: 'UpdateLeadRequest'
    httpMethod: 'POST'
    port: req.param('port') or endpoints.defaults.port
    params: JSON.stringify
      LeadJSON: req.body
    headers: _.merge req.param('headers') or endpoints.defaults.headers

  next()

app.post '/prospects', postNewLead, dockMaster.request

app.listen (port = process.env.PORT or 1338), require('os').hostname(), ->
  console.log '%s listening at %s', app.get('name'), port
