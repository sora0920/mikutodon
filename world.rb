class World < Diva::Model
  register :mastodon, name: "Mastodon"

  field.string :slug, required: true
  field.string :name, required: true
  field.string :host, required: true
  field.string :token, required: true

  def self.build(token, host)
    user = get_user("verify_credentials", {token: token, host: host})[:body]
    self.new(
      slug: "mastodon #{user["acct"]}",
      name: user["username"],
      host: host,
      token: token
    )
  end

#
#  def user=(new_user)
#
#  end
#
#  def icon
#
#  end
#
#  def title
#
#  end
#
#  def post
#
#  end
#
end


