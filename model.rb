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
  field.bool   :sensitive?, required: true
  field.has    :user, MstdnUser, required: true

  entity_class Retriever::Entity::URLEntity

  def perma_link
    link
  end
end

