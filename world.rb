class World < Diva::Model
  register :mastodon, name: "Mastodon"

  field.string :host, required: true
  field.string :token, required: true

#  def user
#
#  end
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


