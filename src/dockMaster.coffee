http   = require 'http'
_      = require 'lodash'
Sanitizer = require 'dockmaster-sanitizer'
endpoints = require '../lib/endpointsConfig'

# Deals with the DockMaster API
class DockMaster
  # merges different configurations for the DockMaster request
  # Sources are req.params, endpoints.routes and endpoints[req.method]
  config: (req, res, next) ->
    path = req.route.path
    if not conf = endpoints.routes[path]?[req.method]
      msg = "ERROR: No config for #{path} with #{req.method}"
      console.log msg
      res.end(msg)

    config = {}
    for opt in ['hostname', 'port', 'httpMethod', 'soapMethod', 'params']
      config[opt] = req.param(opt) or conf[opt] or endpoints.defaults[opt]

    # custom modifications per route
    if req.method is 'POST'
      if req.path is '/prospects' or req.path is '/prospects/:id'
        config.params = JSON.stringify LeadJSON: req.body

    # headers are an object, so need to be deep merged
    config.headers = _.cloneDeep(_.merge req.param('headers') or
      conf.headers or endpoints.defaults.headers)

    res.locals.config = config

    next()

  request: (req, res, next) ->
    options = res.locals.config

    # add content-length header
    if not _.isString options.headers['content-length']
      if _.isNumber options.headers['content-length']
        options.headers['content-length'] += ''
      else
        options.headers['content-length'] = options.params.length

    httpOptions =
      hostname: options.hostname
      port: options.port
      method: options.httpMethod
      path: "/DB2Web.asmx/#{options.soapMethod}JSON"
      headers: options.headers

    extReq = http.request httpOptions, (extRes) ->
      extRes.pipe(new Sanitizer).pipe(res)
    extReq.on 'error', (e) ->
      console.error "ERROR EXTREQ: #{e.message}"
      res.status 500
      res.write e.message
      res.end()
    extReq.write options.params
    extReq.end()

  postNewLead: (req, res, next) ->
    options = res.locals.config

    # add content-length header
    if not _.isString options.headers['content-length']
      if _.isNumber options.headers['content-length']
        options.headers['content-length'] += ''
      else
        options.headers['content-length'] = options.params.length

    httpOptions =
      hostname: options.hostname
      port: options.port
      method: options.httpMethod
      path: "/DB2Web.asmx/#{options.soapMethod}JSON"
      headers: options.headers

    extReq = http.request httpOptions, do (req, res, next) ->
      result = ''

      (extRes) ->
        extRes.setEncoding 'utf8'

        extRes.on 'error', (e) ->
          console.log "ERROR: #{e.message}"

        extRes.on 'data', (chunk) ->
          result += chunk

        extRes.on 'end', ->
          result = (new Sanitizer)._parse result
          # merge new id with existing object
          result = _.merge result, req.body
          if result instanceof Error
            console.error 'sanitizer ERR', result
            res.statusCode = 500
            res.write result.message
            res.end()
          else
            res.write JSON.stringify result
            res.statusCode = 200
            res.end()
    extReq.on 'error', (e) ->
      console.error "ERROR EXTREQ: #{e.message}"
      console.error e
    extReq.write options.params
    extReq.end()

module.exports = new DockMaster
