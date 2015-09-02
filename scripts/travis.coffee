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

url = require 'url'
querystring = require 'querystring'
cp = require 'child_process'
crypto = require 'crypto'

module.exports = (robot) ->

  robot.router.post "/hubot/travis", (req, res) ->
    query = querystring.parse url.parse(req.url).query

    user = {}
    # XXX I just use one
    user.room = process.env.HUBOT_IRC_ROOMS

    try
      payload = JSON.parse req.body.payload
      travis_user_token = process.env.HUBOT_TRAVIS_USER_TOKEN

      # hook validation 
      # http://docs.travis-ci.com/user/notifications/#Authorization-for-Webhooks
      hash = crypto.createHash("sha256")
      hash.update("#{payload.repository.owner_name}/#{payload.repository.name}#{travis_user_token}")
      hexdigest = hash.digest("hex")
      if hexdigest isnt req.headers['authorization']
        robot.send user, "Auth error"
        console.log hexdigest
        console.log req.headers['authorization']
        console.log req.headers
        res.end

      message = "#{payload.status_message.toUpperCase()} build (#{payload.build_url}) on #{payload.repository.name}:#{payload.branch} by #{payload.author_name} with commit (#{payload.compare_url})"
      robot.send user, message
      console.log message

      # XXX dirty shuld call ansible script
      robot.send user, "Starting continuous deploy"

      production_playbook = process.env.HUBOT_ANSIBLE_PRODUCTION_PLAYBOOK
      play = cp.spawn 'ansible-playbook', [production_playbook]
      play.stdout.on 'data', (data) ->
        robot.send(user, data)
      play.stderr.on 'data', (data) ->
        robot.send(user, data)

    catch error
      console.log "travis hook error: #{error}. Payload: #{req.body.payload}"

    res.end JSON.stringify {
      send: true #some client have problems with and empty response, sending that response ion sync makes debugging easier
    }
