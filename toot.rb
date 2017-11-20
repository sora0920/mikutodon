require 'net/http'
require 'uri'
require 'json'

def PostToot(text, vis, cw, account)  
  uri = URI.parse(account[:status_url])
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  req = Net::HTTP::Post.new(uri.request_uri)

  data = {
    status: text,
    visibility: vis,
    spoiler_text: cw
  }.to_json

  token = " Bearer " + account[:token]

  req["Content-Type"] = "application/json"
  req["Authorization"] = token

  req.body = data

  res = https.request(req)


  activity :system,  "#{res.code}\n#{res.message}"
  
end

