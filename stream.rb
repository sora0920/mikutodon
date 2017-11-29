def stream(account, tl, tl_name, toots)
  activity :system, "stream!"

  url = "https://#{account[:host]}/api/v1/streaming?access_token=#{account[:token]}&stream=#{tl}"
  ws = WebSocket::Client::Simple.connect(url)
    ws.on :open do
      puts "こねくと！"
    end

    ws.on :close do |e|
      puts "close"
      p e        
    end

    ws.on :message do |msg|
      toot = JSON.parse(msg.data)
      if toot["event"] == "update"
        toots.push(toot["payload"])
      end
    end

    ws.on :error do |e|
      p e
    end

  loop do
    if ! toots.empty?
      toots.each{ |item|
        timeline(tl_name) << create_toot(item)
        toots.pop(1)
      }
    end

    sleep 1
  end

end


