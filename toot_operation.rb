# frozen_string_literal: true

# ふぁぼのステータスを反転する
# @param [String] id ステータスID
# @param [Hash] account アカウント情報
# @return [nil]
def mstdn_fav(id, account)
  toot_test(id, account).next { |toot|
    uri = if !(toot[:body]["favourited"])
            URI.parse("https://#{account[:host]}/api/v1/statuses/#{id}/favourite")
          else
            URI.parse("https://#{account[:host]}/api/v1/statuses/#{id}/unfavourite")
          end

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    req = Net::HTTP::Post.new(uri.request_uri)

    req["Authorization"] = "Bearer #{account[:token]}"

    https.request(req)
  }.next { |res|
    mikutodon_is_error?(res, "fav")
    # activity :mikutodon_debug_message, "fav: #{res.code} #{res.message}"
  }
end

# ブーストのステータスを反転する
# @param [String] id ステータスID
# @param [Hash] account アカウント情報
# @return [nil]
def mstdn_reblog(id, account)
  toot_test(id, account).next { |toot|
    uri = if !(toot[:body]["reblogged"])
            URI.parse("https://#{account[:host]}/api/v1/statuses/#{id}/reblog")
          else
            URI.parse("https://#{account[:host]}/api/v1/statuses/#{id}/unreblog")
          end

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    req = Net::HTTP::Post.new(uri.request_uri)

    req["Authorization"] = "Bearer #{account[:token]}"

    https.request(req)
  }.next { |res|
    mikutodon_is_error?(res, "reblog")
    # activity :mikutodon_debug_message, "reblog: #{res.code} #{res.message}"
  }
end

# トゥートの確認
# @param [String] id ステータスID
# @param [Hash] account アカウント情報
# @return [Delayer::Deferred::Deferredable] {code:, message:, body:}なオブジェクトを引数にcallbackするDeferred
def toot_test(id, account)
  Thread.new(id, account) { |status_id, acct|
    uri = URI.parse("https://#{acct[:host]}/api/v1/statuses/#{status_id}")

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    req = Net::HTTP::Get.new(uri.path)
    req["Authorization"] = "Bearer #{acct[:token]}"

    https.request(req)
  }.next { |res|
    {
      code: res.code,
      message: res.message,
      body: JSON.parse(res.body)
    }
  }
end

# トゥートを投稿する
# @param [String] text 投稿文字列
# @param [Boolean] cw CWの警告文字列
# @param [Hash] account アカウント情報
# @param [Integer] config visの設定
# @return [nil]
def post_toot(text, cw, account, config)
  Thread.new(text, cw, account, config) { |post_text, cw_text, acct, conf|
    vis = case conf
          when 0 then
            "public"
          when 1 then
            "unlisted"
          when 2 then
            "private"
          when 3 then
            "direct"
          when 4 then
            random_vis
          else
            "public"
          end

    uri = URI.parse("https://#{acct[:host]}/api/v1/statuses")
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    req = Net::HTTP::Post.new(uri.request_uri)

    data = {
      status: post_text,
      visibility: vis,
      spoiler_text: cw_text
    }.to_json

    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{acct[:token]}"

    req.body = data

    https.request(req)
  }.next { |res|
    $toot_result = res.body
    mikutodon_is_error?(res, "toot")
    # activity :mikutodon_debug_message, "toot: #{res.code} #{res.message}"
  }
end

def mikutodon_is_error?(res, type)
  if res.code != "200"
    activity :system, "mikutodonError!\n#{type}: #{res.code} #{res.message}\n#{res.body}"
  else
    activity :mikutodon_debug_message, "#{type}: #{res.code} #{res.message}"
  end
end

# visをランダムに決めて返す
# @return [String] visのステータス文字列
def random_vis
  case rand(1..400)
  when 1..100 then
    "public"
  when 101..200 then
    "unlisted"
  when 201..300  then
    "private"
  when 301..400 then
    "direct"
  else
    activity :mikutodon_debug_message, "0から3までの乱数が0から3以外の数値を出したよ！\nすごいね！どう考えてもバグだね！"
  end
end
