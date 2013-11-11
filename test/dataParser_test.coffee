'use strict'

rawWorkorders = require '../test/fixtures/workorders.json'
parsedWorkorders = require '../test/expected/workorders.json'
parser = require '../lib/dataParser'

# ======== A Handy Little Nodeunit Reference ========
# https://github.com/caolan/nodeunit

# Test methods:
#   test.expect(numAssertions)
#   test.done()
# Test assertions:
#   test.ok(value, [message])
#   test.equal(actual, expected, [message])
#   test.notEqual(actual, expected, [message])
#   test.deepEqual(actual, expected, [message])
#   test.notDeepEqual(actual, expected, [message])
#   test.strictEqual(actual, expected, [message])
#   test.notStrictEqual(actual, expected, [message])
#   test.throws(block, [error], [message])
#   test.doesNotThrow(block, [error], [message])
#   test.ifError(value)

exports['parser'] =
  'workorders': (test) ->
    test.expect 1
    actual = JSON.stringify parser.parse rawWorkorders
    expected = JSON.stringify parsedWorkorders
    test.deepEqual actual, expected, 'Workorders parsed correctly'
    test.done()
