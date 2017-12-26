def parse_name(data)
  if data["account"]["display_name"].empty?
    return data["account"]["username"]
  else
    return data["account"]["display_name"]
  end
end
