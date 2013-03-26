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
heroku = new (require("heroku")).Heroku({key: process.env.HUBOT_HEROKU_API_KEY})

nodelog = (error, result)->
  console.log "---"
  console.log "Error:"
  console.log error
  console.log "---"
  console.log "Result:"
  console.log result

module.exports = (robot)->


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