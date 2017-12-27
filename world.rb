class World < Diva::Model
  register :mikutodon, name: "Mastodon"

  field.string :slug, required: true
  field.string :name, required: true
  field.string :host, required: true
  field.string :token, required: true

  def self.build(token, host)
    user = get_user("verify_credentials", {token: token, host: host})[:body]
    self.new(
      slug: "mastodon#{user["id"]}",
      name: user["username"],
      host: host,
      token: token
    )
  end
end


