def create_notification(json)
  puts "teset"
  data = JSON.parse(json)

  case data["type"]
    when "favourite" then
      name =  if data["account"] ["display_name"].empty?
        data["account"] ["username"]
      else
        data["account"] ["display_name"]
      end

      user_name =  if data["status"]["account"] ["display_name"].empty?
        data["status"]["account"] ["username"]
      else
        data["status"]["account"] ["display_name"]
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
      activity :mstdn_notification, "#{name}さんにふぁぼられました。\n\n#{user_name}: #{toot_body}"
    when "reblog" then
      name =  if data["account"] ["display_name"].empty?
        data["account"] ["username"]
      else
        data["account"] ["display_name"]
      end

      user_name =  if data["status"]["account"] ["display_name"].empty?
        data["status"]["account"] ["username"]
      else
        data["status"]["account"] ["display_name"]
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
      activity :mstdn_notification, "#{name}さんにぶーすとされました。\n\n#{user_name}: #{toot_body}"
    when "follow" then
      name =  if data["account"] ["display_name"].empty?
        data["account"] ["username"]
      else
        data["account"] ["display_name"]
      end
      activity :mstdn_notification, "#{name}(#{data["account"]["acct"]})にフォローされました"
    else 
      puts data
  end 
end
