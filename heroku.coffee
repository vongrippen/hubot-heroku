# Description:
#   A simple interaction with Heroku command line
#
# Dependencies:
#   "heroku": "https://github.com/vongrippen/node-heroku.git"
#
# Notes:
#   Dependency should change once pull request is accepted and released to npm
#
# Configuration:
#   HUBOT_HEROKU_API_KEY
#
# Commands:
#   hubot heroku <app> config - Display the config vars for an app
#   hubot heroku <app> config:set <variable>=<value> - Set a config var for an app
#   hubot heroku <app> config:unset <variable> - Delete a config var for an app
#   hubot heroku <app> ps - List running Heroku processes for an app
#   hubot heroku <app> ps:restart [process] - Restart Heroku process or all processes
#   hubot heroku <app> ps:scale <process>=<count> - Scale Heroku processes
#   hubot heroku <app> ps:stop <process> - Stop Heroku process (restarts on a new dyno)
heroku = new (require("heroku")).Heroku({key: process.env.HUBOT_HEROKU_API_KEY})

nodelog = (error, result)->
  console.log "---"
  console.log "Error:"
  console.log error
  console.log "---"
  console.log "Result:"
  console.log result

module.exports = (robot)->


  ###
  #
  # heroku config
  #
  ###
  robot.respond /heroku (.*) config:set (.*)=(.*)/i, configSet
  robot.respond /heroku (.*) config:add (.*)=(.*)/i, configSet
  configSet = (msg)->
    vars = {}
    vars["#{msg.match[2]}"] = msg.match[3]
    heroku.put_config_vars msg.match[1], vars, (error, result)->
      output = []
      for key, value of result
        output.push "#{key}: #{value}"
      msg.send output.join("\n")

  robot.respond /heroku (.*) config:unset (.*)/i, (msg)->
    heroku.delete_config_var msg.match[1], msg.match[2], (error, result)->
      output = []
      for key, value of result
        output.push "#{key}: #{value}"
      msg.send output.join("\n")

  robot.respond /heroku (.*) config$/i, (msg)->
    heroku.get_config_vars msg.match[1], (error, result)->
      output = []
      for key, value of result
        output.push "#{key}: #{value}"
      msg.send output.join("\n")

  ###
  #
  # herok ps
  #
  ###
  herokuPs = (msg)->
    heroku.get_ps msg.match[1], (error, result)->
      nodelog error, result
      processes = {}

      for p in result
        processes[p.process.split('.')[0]] ?=
          command: p.command
          processes: []

        processes[p.process.split('.')[0]].processes.push [
            "#{p.process}: #{p.state}"
            p.transitioned_at.split(' ')[0]
            p.transitioned_at.split(' ')[1]
            "(~ #{p.pretty_state.split(' ')[2]} ago)"
          ].join ' '
      output = []
      for k, v of processes
        output.push "== #{k}: `#{v.command}`"
        for p in v.processes
          output.push p
        output.push ''
      msg.send output.join "\n"

  robot.respond /heroku (.*) ps$/i, herokuPs

  robot.respond /heroku (.*) ps:restart$/i, (msg)->
    heroku.post_ps_restart msg.match[1], (error, result)->
      heroku Ps msg

  robot.respond /heroku (.*) ps:restart (.*)/i, (msg)->
    heroku.post_ps_restart msg.match[1], {ps: msg.match[2]}, (error, result)->
      heroku Ps msg

  robot.respond /heroku (.*) ps:scale (.*)=(.*)/i, (msg)->
    heroku.post_ps_scale msg.match[1], msg.match[2], msg.match[3], (error, result)->
      heroku Ps msg

  robot.respond /heroku (.*) ps:stop (.*)/i, (msg)->
    heroku.post_ps_stop msg.match[1], {ps: msg.match[2]}, (error, result)->
      heroku Ps msg
