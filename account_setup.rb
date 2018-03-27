def create_link(host, c_name)
  begin 
  uri = URI.parse("https://#{host}/api/v1/apps")

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  req = Net::HTTP::Post.new(uri.request_uri)

  req["Content-Type"] = "application/json"

  if c_name.empty?
    c_name = "mikutter(mikutodon)"
  end
  data = {
    client_name: c_name,
    redirect_uris: "urn:ietf:wg:oauth:2.0:oob",
    scopes: "read write follow"
  }.to_json

  req.body = data
  
  res = https.request(req)

  mikutodon_is_error?(res, "CreateApp")
  
  begin
    @app = JSON.parse(res.body)
  rescue
    @app = ""
  end

  if res.code == "200"
    return {
      "result" => "https://#{host}/oauth/authorize?client_id=#{@app["client_id"]}&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=read%20write%20follow",
      "code" =>  res.code
    }
  else
    return {
      "result" => res.message,
      "code" => res.code
    }
  end
  rescue
    return {
      "result" => "名前またはサービスが不明です",
      "code" => "NaN"
    }
  end
end

def get_token(auth_code, host)
  begin
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
    
    begin 
      result = JSON.parse(res.body)
    rescue
      result = ""
    end

    if res.code == "200"
      return {
        "result" => result["access_token"],
        "code" => res.code
      }
    else
      return {
        "result" => res.message,
        "code" => res.code
      }
    end
  rescue
    return {
      "result" => "なにかがおかしいです",
      "code" => "NaN"
    }
  end
end
