class World < Diva::Model
  register :mikutodon, name: "Mastodon"

  field.string :id, required: true
  field.string :slug, required: true
  field.string :name, required: true
  field.string :host, required: true
  field.string :token, required: true

  def self.build(token, host)
    user = get_user("verify_credentials", {token: token, host: host})[:body]
    self.new(
      id: user["id"],
      slug: "mastodon #{user["username"]}",
      name: user["username"],
      host: host,
      token: token
    )
  end

  def initialize(hash)
    super(hash)
  end

  def title
    "#{self.name}@#{self.host}"
  end

  def icon
    get_user("verify_credentials", {token: self.token, host: self.host})[:body]["avatar"]
  end

  def to_hash
    super.merge(user: {id: self.id,
                       idname: "#{self.name}@#{self.host}",
                       name: self.name,
                       profile_image_url: self.icon})
  end

#  def post(to: nil, message:, **kwrest)
#    post_toot(message, cw, {token: self.token, host: self.host}, UserConfig[:mastodon_vis])
#  end
#
#  def postable?(world=nil)
#    # test
#  end
end


