require 'net/http'
require 'uri'
require 'json'

def post_toot(text, cw, account, config)  


  vis = 
    case config
      when 0 then
        vis = "public"
      when 1 then
        vis = "unlisted"
      when 2 then
        vis = "private"
      when 3 then
        vis = "direct"
      when 4 then
        case random.rand(1..400)
        when 1..100 then
          vis = "public"
        when 101..200 then
          vis = "unlisted"
        when 201..300  then
          vis = "private"
        when 301..400 then
          vis = "direct"
        else
          activity :system, "0から3までの乱数が0から3以外の数値を出したよ！\nすごいね！どう考えてもバグだね！"
        end
      else
        vis = "public"
      end
  
  

  
  
  uri = URI.parse("https://#{account[:host]}/api/v1/statuses")
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

  $toot_result = res.body
  activity :system,  "#{res.code}\n#{res.message}"
  
end

