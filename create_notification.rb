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


