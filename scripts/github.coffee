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

module.exports = (robot) ->
  robot.router.post '/hubot/github_hook/:room', (req, res) ->
    room   = req.params.room
    raw_payload = req.rawBody
    github_secret = process.env.HUBOT_REPO_GITHUB_SECRET

    # sha1 key must be a buffer
    hmac = crypto.createHmac("sha1", new Buffer(github_secret))
    hmac.update raw_payload
    digest = hmac.digest 'hex'
    if "sha1=#{digest}" isnt req.headers['x-hub-signature']
      console.log "Auth error"
      res.json 401, { send: true, error: true }
      return

    robot.messageRoom room, "#{req.body.pusher.name} pushed to #{req.body.repository.name}"

    res.json { send: true }
