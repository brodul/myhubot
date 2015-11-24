# Description:
#   Find the build status of an open-source project on Travis
#   Can also notify about builds, just enable the webhook notification on travis http://about.travis-ci.org/docs/user/build-configuration/ -> 'Webhook notification'
#
# Dependencies:
#
# Configuration:
#   None
#
# Commands:
#   None
#

crypto = require 'crypto'
request = require 'request'

jar = request.jar()

email = process.env.HUBOT_SEMAPHORE_EMAIL
password = process.env.HUBOT_SEMAPHORE_PASSWORD

authenticate = ->
  request(
    uri: 'http://history.brodul.org:9998/auth/password',
    method: "POST",
    jar: jar,
    form:
      auth: email,
      password: password,
    , (error, response, body) ->
      console.log body
      console.log jar.getCookies('http://history.brodul.org:9998')
  )

module.exports = (robot) ->

  robot.respond /semaphore deploy/i, (res) ->
    request(
      uri: 'http://history.brodul.org:9998/',
      method: "GET",
      jar: jar
      , (error, response, body) ->
        console.log response.statusCode
        if response.statusCode is 403
          authenticate()
        console.log body
        console.log jar.getCookies('http://history.brodul.org:9998')
    )
