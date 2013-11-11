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

  parse: (data) -> data = unwrap data

module.exports = new DataParser