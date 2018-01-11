# タイムラインのストリームをスタート
def mikutodon_start(host, token, name)
  Thread.new{
    stream(host, token, "user", :"MikutodonHomeTimeline_#{name}")
  }
  Thread.new{
    stream(host, token, "public:local", :"MikutodonLocalTimeline_#{name}")
  }
  Thread.new{
    stream(host, token, "public", :"MikutodonPublicTimeline_#{name}")
  }

end

def stream(host, token, tl, tl_name)
  EM.run do
    ws = Faye::WebSocket::Client.new(
      "wss://#{host}/api/v1/streaming?access_token=#{token}&stream=#{tl}",
    )
    ws.on :open do |e|
      puts "こねくと！"
      $tl_close = false
    end

    ws.on :error do |e|
      p e
      activity :mikutodon_debug_message, "えらー！\n#{e}"
    end

    ws.on :close do |e|
      puts "connection close."
      p e
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


