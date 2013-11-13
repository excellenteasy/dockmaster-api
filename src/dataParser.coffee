"use strict"
_ = require 'lodash'

# Simplify raw DockMaster API data to what you would expect from a REST API
# or the other way around.
class DataParser
  unwrap = (data) ->
    keys = _.keys(data)
    if _.isObject(data) and not _.isArray data
      if keys.length is 1
        return unwrap data[_.keys(data)?[0]]
      else
        _.each keys, (key) ->
          if _.isObject(data[key]) or _.isArray(data[key])
            data[key] = unwrap data[key]
        return data
    else if _.isArray data
      result = []
      _.each data, (item) ->
        result.push unwrap item
      return result

  parse: (data) ->
    # capture erros returned form the DockMaster API
    regex = /\{"Message":"(.+)"\}/
    if capture = data.match regex
      return new Error capture[1]

    try
      data = JSON.parse data
    catch e
      console.error e
      console.log "initial response: #{data}"
      return new Error "unable to parse initial response: "

    # We begin to untangle the mess that is returned by the API
    data = data.d
    # If the response is empty, it will look something like '{"workorders":}'.
    # In that case, we need to return an empty object or array.
    if /^\{\"[a-zA-Z]+\"\:\}$/.test data
      # TODO: allow for other empty types like {} or "", depending on endpoint
      data = []
    # When the response does carry data, sometimes JSON.parse works, sometimes
    # not. Hence, we need try and if it fails continue untangling the
    # "custom JSON" (=invalid JSON) that was sent.
    else
      try
        data = JSON.parse data
      catch e
        try
          data = eval("(function(){return #{data}})")()
        catch err
          data = new Error 'unable to parse the response'

    # Now, we can unwrap the parsed data
    unwrap data

module.exports = new DataParser
