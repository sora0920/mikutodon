def create_link(host)
  uri = URI.parse("https://#{host}/api/v1/apps")

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  req = Net::HTTP::Post.new(uri.request_uri)

  req["Content-Type"] = "application/json"

  data = {
    client_name: "mikutter",
    redirect_uris: "urn:ietf:wg:oauth:2.0:oob",
    scopes: "read write follow"
  }.to_json

  req.body = data
  
  res = https.request(req)

  mikutodon_is_error?(res, "CreateApp")
  
  @app = JSON.parse(res)

  return "https://#{host}/oauth/authorize?client_id=#{@app["client_id"]}&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=read%20write%20follow"
end

def get_token(auth_code)
  uri = URI.parse("https://#{host}/oauth/token")

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  req = Net::HTTP::Post.new(uri.request_uri)

  req["Content-Type"] = "application/json"

  data = {
    grant_type: "authorization_code",
    redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
    client_id: @app["client_id"],
    client_secret: @app["client_secret"],
    code: auth_code
  }.to_json

  req.body = data
  
  res = https.request(req)

  mikutodon_is_error?(res, "GetToken")
  
  return res
end
