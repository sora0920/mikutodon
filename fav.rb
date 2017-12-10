require 'net/http'
require 'uri'
require 'json'
require_relative "./toot_test"

def mstdn_fav(id, account) 
  toot = toot_test(id, account)

  if !(toot["body"] ["favourited"])
    uri = URI.parse("https://#{account[:host]}/api/v1/statuses/#{id}/favourite")
  else
    uri = URI.parse("https://#{account[:host]}/api/v1/statuses/#{id}/unfavourite")
  end

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  req = Net::HTTP::Post.new(uri.request_uri)

  token = " Bearer " + account[:token]

  req["Authorization"] = token


  res = https.request(req)

  activity :system,  "#{res.code}\n#{res.message}"
end

