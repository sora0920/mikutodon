def get_user(id, account)
  uri = URI.parse("https://#{account[:host]}/api/v1/accounts/#{id}")
  token = " Bearer " + account[:token]

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  req = Net::HTTP::Get.new(uri.path)
  req["Authorization"] = token

  res = https.request(req)

  return  ({'code' => res.code,
            'message' => res.message,
            'body' => JSON.parse(res.body)})

end
