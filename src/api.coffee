'use strict'

# START Dependencies
express = require 'express'
dockMaster = require '../lib/dockMaster'
_ = require 'lodash'
# END Dependencies

# Prevent server from going down by unexpected errors
process.on 'uncaughtException', (err) ->
  console.log '>>> uncaught exception !', err
  console.log err.stack

app = express()
app.set 'name', 'DockMaster REST API'
app.set 'version', '0.0.0'

app.use express.logger()

app.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
  res.header 'Access-Control-Allow-Methods', 'POST, GET, PUT, DELETE, OPTIONS'
  next()

app.get '/workorders', dockMaster.config, dockMaster.request
app.get '/workorders/:id', dockMaster.config, dockMaster.request
app.get '/prospects', dockMaster.config, dockMaster.request
app.get '/customers', dockMaster.config, dockMaster.request

app.listen (port = 1338), ->
  console.log '%s listening at %s', app.get('name'), port
