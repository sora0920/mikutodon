class World < Diva::Model
  register :mastodon, name: "Mastodon"

  field.string :host, required: true
  field.string :token, required: true

  def self.build(token)
    world = new(token: token, host: host)
    world.user = user
  end

  def user
    MstdnUser.new()
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


