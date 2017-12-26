def mstdn_fav(id, account)
  toot = toot_test(id, account)

  if !(toot["body"]["favourited"])
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

  mikutodon_is_error?(res, "fav")
  # activity :mikutodon_debug_message, "fav: #{res.code} #{res.message}"
end


def mstdn_reblog(id, account)
  toot = toot_test(id, account)

  if !(toot["body"]["reblogged"])
    uri = URI.parse("https://#{account[:host]}/api/v1/statuses/#{id}/reblog")
  else
    uri = URI.parse("https://#{account[:host]}/api/v1/statuses/#{id}/unreblog")
  end

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  req = Net::HTTP::Post.new(uri.request_uri)

  token = " Bearer " + account[:token]

  req["Authorization"] = token


  res = https.request(req)

  mikutodon_is_error?(res, "reblog")
  # activity :mikutodon_debug_message, "reblog: #{res.code} #{res.message}"
end

def toot_test(id, account)
  uri = URI.parse("https://#{account[:host]}/api/v1/statuses/#{id}")
  token = " Bearer " + account[:token]

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  req = Net::HTTP::Get.new(uri.path)
  req["Authorization"] = token

  res = https.request(req)

  return  ({'code' => res.code,
            'message' => res.message,
            'body' => JSON.parse(res.body)})

end


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
        case rand(1..400)
        when 1..100 then
          vis = "public"
        when 101..200 then
          vis = "unlisted"
        when 201..300  then
          vis = "private"
        when 301..400 then
          vis = "direct"
        else
          activity :mikutodon_debug_message, "0から3までの乱数が0から3以外の数値を出したよ！\nすごいね！どう考えてもバグだね！"
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
  mikutodon_is_error?(res, "toot")
  # activity :mikutodon_debug_message, "toot: #{res.code} #{res.message}"

end

def mikutodon_is_error?(res, type)
  if res.code != "200"
    activity :system, "mikutodonError!\n#{type}: #{res.code} #{res.message}\n#{res.body}"
  else
    activity :mikutodon_debug_message, "#{type}: #{res.code} #{res.message}"
  end
end

