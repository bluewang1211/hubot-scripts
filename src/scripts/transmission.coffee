#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_TRANSMISSION_USER - Transmission HTTP username
#   HUBOT_TRANSMISSION_PASSWORD - Transmission HTTP password
#   HUBOT_TRANSMISSION_URL - Where Transmission lives
#
# Commands:
#   torrents - Get a list of open torrents
#
# Author:
#   lucaswilric

url = process.env.HUBOT_TRANSMISSION_URL
user = process.env.HUBOT_TRANSMISSION_USER
password = process.env.HUBOT_TRANSMISSION_PASSWORD

get_torrents = (msg, session_id = '', rec_count = 0) ->
  return if rec_count > 4
  msg.http(url)
    .auth(user, password)
    .header('X-Transmission-Session-Id', session_id)
    .post(JSON.stringify({method: "torrent-get", arguments: { fields: ["id", "name", "downloadDir", "percentDone", "files", "isFinished"]}})) (err, res, body) ->
      if res.statusCode == 409
        get_torrents(msg, res.headers['x-transmission-session-id'], rec_count + 1)
      else
        response = ''
        torrents = JSON.parse(body).arguments.torrents
        if torrents.length == 0
          msg.send "There aren't any torrents loaded right now."
          return
        response += "\n[#{100 * t.percentDone}%] #{t.name}" for t in torrents
        msg.send response

module.exports = (robot) ->
  robot.respond /torrents/i, (msg) ->
    get_torrents(msg)
    
  robot.respond /where('s| is) transmission\??/i, (msg) ->
    msg.send "Transmission is at " + url
