# 表示条件を満たすデータに加工
def create_toot(status)
  status_parse = JSON.parse(status)

  created_time = status_parse["created_at"]

  data = if status_parse["reblog"].empty?
    status_parse
  else
    status_parse["reblog"]
  end

  if !(data["spoiler_text"].empty?)
    cw_body = Nokogiri::HTML.parse(data["spoiler_text"],nil,"UTF-8")
    body = Nokogiri::HTML.parse(data["content"],nil,"UTF-8")

    cw_body.search('br').each do |br|
      br.replace("\n")
    end
    body.search('br').each do |br|
      br.replace("\n")
    end

    toot_body = cw_body.text + "\n\n" + body.text
  else
    # HTMLのParse

    body = Nokogiri::HTML.parse(data["content"],nil,"UTF-8")

    body.search('br').each do |br|
      br.replace("\n")
    end

    toot_body = body.text

  end

  user_name = if data["account"]["display_name"].empty?
    data["account"]["username"]
  else
    data["account"]["display_name"]
  end


  user = Plugin::Mikutodon::User.new_ifnecessary(
    name: user_name,
    link: data["account"]["url"],
    created: Time.parse(data["account"]["created_at"]).localtime,
    profile_image_url: data["account"]["avatar"],
    id: data["account"]["id"].to_i,
    idname: data["account"]["acct"]
  )

  toot = Plugin::Mikutodon::Toot.new_ifnecessary(
    id: data["id"].to_i,
    link: data["url"],
    description: toot_body,
    visibility: data["visibility"],
    created: Time.parse(created_time).localtime,
    user: user,
    favorite_count: data["favourites_count"],
    retweet_count: data["reblogs_count"]
  )

  ary = []
  ary.push(toot)

  return ary
end

def create_notification(json)
  data = JSON.parse(json)

  case data["type"]
    when "favourite" then
      user_name =  if data["status"]["account"]["display_name"].empty?
        data["status"]["account"]["username"]
      else
        data["status"]["account"]["display_name"]
      end

      if !(data["status"]["spoiler_text"].empty?)
        cw_body = Nokogiri::HTML.parse(data["status"]["spoiler_text"],nil,"UTF-8")
        body = Nokogiri::HTML.parse(data["status"]["content"],nil,"UTF-8")

        cw_body.search('br').each do |br|
          br.replace("\n")
        end
        body.search('br').each do |br|
          br.replace("\n")
        end

        toot_body = cw_body.text + "\n\n" + body.text
      else
        # HTMLのParse

        body = Nokogiri::HTML.parse(data["status"]["content"],nil,"UTF-8")

        body.search('br').each do |br|
          br.replace("\n")
        end

        toot_body = body.text
      end
      activity :mstdn_fav, "#{parse_name(data)}さんにふぁぼられました。\n\n#{user_name}: #{toot_body}"

    when "reblog" then
      user_name =  if data["status"]["account"]["display_name"].empty?
        data["status"]["account"]["username"]
      else
        data["status"]["account"]["display_name"]
      end

      if !(data["status"]["spoiler_text"].empty?)
        cw_body = Nokogiri::HTML.parse(data["status"]["spoiler_text"],nil,"UTF-8")
        body = Nokogiri::HTML.parse(data["status"]["content"],nil,"UTF-8")

        cw_body.search('br').each do |br|
          br.replace("\n")
        end
        body.search('br').each do |br|
          br.replace("\n")
        end

        toot_body = cw_body.text + "\n\n" + body.text
      else
        # HTMLのParse

        body = Nokogiri::HTML.parse(data["status"]["content"],nil,"UTF-8")

        body.search('br').each do |br|
          br.replace("\n")
        end

        toot_body = body.text
      end
      activity :mstdn_reblog, "#{parse_name(data)}さんにぶーすとされました。\n\n#{user_name}: #{toot_body}"

    when "follow" then
      activity :mstdn_follow, "#{parse_name(data)}(#{data["account"]["acct"]})にフォローされました"

    when "mention" then
      if !(data["status"]["spoiler_text"].empty?)
        cw_body = Nokogiri::HTML.parse(data["status"]["spoiler_text"],nil,"UTF-8")
        body = Nokogiri::HTML.parse(data["status"]["content"],nil,"UTF-8")

        cw_body.search('br').each do |br|
          br.replace("\n")
        end
        body.search('br').each do |br|
          br.replace("\n")
        end

        toot_body = cw_body.text + "\n\n" + body.text
      else
        # HTMLのParse

        body = Nokogiri::HTML.parse(data["status"]["content"],nil,"UTF-8")

        body.search('br').each do |br|
          br.replace("\n")
        end

        toot_body = body.text
      end
      activity :mstdn_mention, "#{parse_name(data)}から返信があります。\n\n#{toot_body}"
    else
      activity :mikutodon_debug_message, data
  end
end


def parse_name(data)
  if data["account"]["display_name"].empty?
    return data["account"]["username"]
  else
    return data["account"]["display_name"]
  end
end

def mikutodon_is_error?(res, type)
  if res.code != "200"
    activity :system, "mikutodonError!\n#{type}: #{res.code} #{res.message}\n#{res.body}"
  else
    activity :mikutodon_debug_message, "#{type}: #{res.code} #{res.message}"
  end
end
