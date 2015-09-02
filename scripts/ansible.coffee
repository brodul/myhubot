# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

cp = require 'child_process'

module.exports = (robot) ->

  robot.respond /deploy/i, (msg) ->

    role = 'authorized'
    unless robot.auth.hasRole(msg.envelope.user, role)
      msg.send "Access denied. You must have this role to use this command: #{role}"
      return

    process.env.PYTHONUNBUFFERED = 1
    # playbook to exectute (path)
    production_playbook = process.env.HUBOT_ANSIBLE_PRODUCTION_PLAYBOOK
    play = cp.spawn "ansible-playbook", [production_playbook]

    msg.send "Ansible deploy in progress ..."

    # XXX very noisy
    play.stdout.on 'data', (data) ->
      msg.send 'stdout: ' + data
      console.log 'stdout: ' + data

    play.stderr.on 'data', (data) ->
      msg.send 'stderr: ' + data
      console.log 'stderr: ' + data

  robot.respond /aping/i, (msg) ->

    role = 'authorized'
    unless robot.auth.hasRole(msg.envelope.user, role)
      msg.send "Access denied. You must have this role to use this command: #{role}"
      return

    spawn = require('child_process').spawn

    command = "ansible localhost -m ping"

    msg.send "Ansible ping ..."

    @exec = require('child_process').exec

    @exec command, (error, stdout, stderr) ->
#      msg.send error
      msg.send stdout
      msg.send stderr
