# タイムラインのストリームをスタート
def mikutodon_start(host, token, name)
  Thread.new{
    toots_home = []
    stream(host, token, "user", :"MikutodonHomeTimeline_#{name}", toots_home)
  }
  Thread.new{
    toots_local = []
    stream(host, token, "public:local", :"MikutodonLocalTimeline_#{name}", toots_local)
  }
  Thread.new{
    toots_public = []
    stream(host, token, "public", :"MikutodonPublicTimeline_#{name}", toots_public)
  }

end

def stream(host, token, tl, tl_name, toots)
  EM.run do
    ws = Faye::WebSocket::Client.new(
      "wss://#{host}/api/v1/streaming?access_token=#{token}&stream=#{tl}",
    )
    ws.on :open do |e|
			puts "Open!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      activity :mikutodon_debug_message, "こねくと！"
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


