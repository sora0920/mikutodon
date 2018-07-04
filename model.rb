Plugin.create(:mikutodon) do
  module Plugin::Mikutodon
    class User < Retriever::Model
      include Retriever::Model::UserMixin

      register :mstdn_user, name: "Mastodon Timeline User"
      field.string :name, required: true
      field.string :link
      field.time   :created
      field.string :profile_image_url
      field.int    :id
      field.string :idname

      def perma_link
        Diva::URI(link)
      end

      def modified
        created
      end
    end

    class Emoji < Retriever::Model
      field.string :name, required: true
      field.string :url, required: true 

      def perma_link
        Diva::URI(url)
      end

      def shortcode
        ":#{name}:"
      end
    end


    class Toot < Retriever::Model
      include Retriever::Model::MessageMixin

      register :mstdn_toot, name: "Mastodon Timeline Toot"

      field.int    :id
      field.string :link
      field.string :description
      field.string :visibility
      field.time   :created
      field.int    :favorite_count, required: true
      field.int    :retweet_count, required: true
      field.has    :user, User, required: true
      field.has    :emojis, [Emoji], required: true

      entity_class Retriever::Entity::URLEntity

      def perma_link
        Diva::URI(link)
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

        world = new(
          id: user["id"],
          slug: "mastodon-#{host}-#{user["username"]}".to_sym,
          name: user["username"],
          host: host,
          token: token
        )

        user_name = if user["display_name"].empty?
          user["username"]
        else
          user["display_name"]
        end

        world.user = Plugin::Mikutodon::User.new(
          name: user_name,
          link: user["url"],
          created: Time.parse(user["created_at"]).localtime,
          profile_image_url: user["avatar"],
          id: user["id"].to_i,
          idname: user["acct"]
        )
        world
      end

      def initialize(hash)
        super(hash)
        Thread.new{
          mikutodon_start(self.host, self.token, self.title) 
        }
      end

      def title
        "#{self.name}@#{self.host}"
      end

      def icon 
        Plugin.filtering(:photo_filter, "#{self.icon_url}", [])[1].first
      end

      def icon_url
        get_user("verify_credentials", {token: self.token, host: self.host})[:body]["avatar"]
      end

      def user
        @user || Plugin::Mikutodon::User.new(self[:user])
      end

      def user=(new_user)
        @user = new_user
      end

      def to_hash
        super.merge(user: {id: self.id,
                           idname: self.title,
                           name: self.name,
                           profile_image_url: self.icon_url})
      end

    end
  end
end
