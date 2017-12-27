def stream(account, tl, tl_name, toots)
  EM.run do
    ws = Faye::WebSocket::Client.new(
      "wss://#{account[:host]}/api/v1/streaming?access_token=#{account[:token]}&stream=#{tl}",
    )
    ws.on :open do |e|
      activity :mikutodon_debug_message, "こねくと！"
      $tl_close = false
    end

    ws.on :error do |e|
      activity :mikutodon_debug_message, "えらー！\n#{e}"
    end

    ws.on :close do |e|
      puts "connection close."
      puts e
      activity :mikutodon_debug_message, "こねくしょんくろーず！"
      $tl_close = true
    end

    ws.on :message do |msg|
      toot = JSON.parse(msg.data)
      if toot["event"] == "update"
        Plugin.call :extract_receive_message, tl_name, create_toot(toot["payload"])
      elsif toot["event"] == "notification"
        create_notification(toot["payload"])
      else
        puts toot
      end
    end
  end
end

