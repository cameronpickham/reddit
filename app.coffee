request = require 'request'
config  = require './config'

username = config.me2

all = []

pullData = (after, cb) ->
  options =
    uri: "http://www.reddit.com/user/#{username}/comments.json"
    qs:
      limit: 100
      after: after

  request.get options, (err, res, body) =>
    body = JSON.parse body
    items = body.data.children
    return cb(items)

scrape = (cb) ->
  after = null

  process = (items) =>
    return cb() if items.length is 0

    for item in items
      all.push { body: item.data.body, ups: item.data.ups, created_utc: item.data.created_utc, name: item.data.name }

    after = items[items.length-1].data.name
    
    pullData(after, process)

  pullData(after, process)

scrape ->
  all.sort (a, b) -> a.ups - b.ups
  console.log all
