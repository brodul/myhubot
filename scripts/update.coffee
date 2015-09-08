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
cp = require 'child_process'
crypto = require 'crypto'

module.exports = (robot) ->

  robot.router.post "/hubot/update/github_hook", (req, res) ->

    # should be more DRY
    user = {}
    # XXX I just use one
    user.room = process.env.HUBOT_IRC_ROOMS

    try
      raw_payload = req.body.payload
      payload = JSON.parse raw_payload
      github_secret = process.env.HUBOT_UPDATE_GITHUB_SECRET

      # validate push hook
      hmac = crypto.createHmac("md5", github_secret)
      hmac.update(raw_payload)
      if hmac.digest('hex') isnt req.headers['X-Hub-Signature']
        robot.send user, "Auth error"
        console.log hexdigest
        console.log req.headers['X-Hub-Signature']
        console.log req.headers
        res.end

      message = "Recived hubot restart hook.\nPulling new source."
      robot.send user, message
      console.log message
      git_result = cp.spawn 'git', ['pull']

    catch error
      console.log "hubot update github hook error: #{error}. Payload: #{req.body.payload}"

    res.end JSON.stringify {
      send: true #some client have problems with and empty response, sending that response ion sync makes debugging easier
    }
