class MstdnUser < Retriever::Model
  include Retriever::Model::UserMixin

  register :mstdn_user, name: "Mastodon Timeline User"
  field.string :name, required: true
  field.string :link
  field.time   :created
  field.string :profile_image_url
  field.int    :id
  field.string :idname

  def perma_link
    link
  end

  def modified
    created
  end
end

class MstdnToot < Retriever::Model
  include Retriever::Model::MessageMixin

  register :mstdn_toot, name: "Mastodon Timeline Toot"

  field.int    :id
  field.string :link
  field.string :description
  field.time   :created
  field.int    :favorite_count, required: true
  field.int    :retweet_count, required: true
  field.has    :user, MstdnUser, required: true

  entity_class Retriever::Entity::URLEntity

  def perma_link
    link
  end
end


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

#  def initialize(hash)
#    super(hash)
#  end

  def title
    "#{self.name}@#{self.host}"
  end

  def icon 
    Plugin.filtering(:photo_filter, "#{self.icon_url}", [])[1].first
  end

  def icon_url
    get_user("verify_credentials", {token: self.token, host: self.host})[:body]["avatar"]
  end

  def to_hash
    super.merge(user: {id: self.id,
                       idname: self.title,
                       name: self.name,
                       profile_image_url: self.icon_url})
  end

  def post(to: nil, message:, **kwrest)
    post_toot(message, cw, {token: self.token, host: self.host}, "public")
  end

  def postable?(world=nil)
    true
  end
end


