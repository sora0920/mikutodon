class MstdnUser < Retriever::Model
  include Retriever::Model::UserMixin
  
  register :mstdn_user, name: "Mastodon Timeline User"
  field.string :name, required: true
  field.string :link
  field.time   :created
  field.string :profile_image_url
  field.int    :id
end

class MstdnToot < Retriever::Model
  include Retriever::Model::MessageMixin

  register :mstdn_toot, name: "Mastodon Timeline Toot"

  field.int    :id
  field.string :link
  field.string :description
  field.time   :created
  field.has    :user, MstdnUser, required: true
  
  entity_class Retriever::Entity::URLEntity  
end

