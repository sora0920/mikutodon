# タイムラインのストリームをスタート
def mikutodon_start(host, token, name)
  Thread.new{
    stream(host, token, "user", :"MikutodonHomeTimeline_#{name}")
  }
  Thread.new{
    stream(host, token, "public/local", :"MikutodonLocalTimeline_#{name}")
  }
  Thread.new{
    stream(host, token, "public", :"MikutodonPublicTimeline_#{name}")
  }

end

def stream(host, token, tl, tl_name)
  uri = URI.parse("https://#{host}/api/v1/streaming/#{tl}")
  buffer = ""

  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |https|
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{token}"

    https.request(req) do |res|
      res.read_body do |chunk|
        buffer += chunk
        while index = buffer.index(/\r\n\r\n|\n\n/)
          stream = buffer.slice!(0..index)
          json = sse_parse(stream)
          if json[:event] == "update"
            Plugin.call :extract_receive_message, tl_name, create_toot(json[:body])
          elsif json[:event] == "notification"
            # create_notification(json[:body])
          end

        end
      end
    end
  end

end

def sse_parse(stream)
  data = ""
  name = nil

  stream.split(/\r?\n/).each do |part|
    /^data:(.+)$/.match(part) do |m|
      data += m[1].strip
      data += "\n"
    end
    /^event:(.+)$/.match(part) do |m|
      name = m[1].strip
    end
  end

  return {
    event: name,
    body: data.chomp!
  }
end
