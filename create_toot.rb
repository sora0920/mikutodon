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


  user = MstdnUser.new_ifnecessary(
    name: user_name,
    link: data["account"]["url"],
    created: Time.parse(data["account"]["created_at"]).localtime,
    profile_image_url: data["account"]["avatar"],
    id: data["account"]["id"].to_i,
    idname: data["account"]["acct"]
  )

  toot = MstdnToot.new_ifnecessary(
    id: data["id"].to_i,
    link: data["url"],
    description: toot_body,
    created: Time.parse(created_time).localtime,
    user: user,
    favorite_count: data["favourites_count"],
    retweet_count: data["reblogs_count"],
    sensitive?: data["sensitive"]
  )

  ary = []
  ary.push(toot)

  return ary
end
