require "net/http"
require "uri"
require "open-uri"

def get_sse(host, token)
  uri = URI.parse("https://#{host}/api/v1/streaming/user")

  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |https|
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{token}"

    https.request(req) do |res|
      res.read_body do |body|
        puts body
      end
    end
  end

end

get_sse(ARGV[0], ARGV[1])
