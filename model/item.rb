module Plugin::Mastodon
  class Item < Retriever::Model
    include Retriever::Model::MessageMixin

    register :mastodon, name: "Mastodon Timeline"

    field.string :guid
    field.string :link
    field.string :title, required: true
    field.string :description
    field.time   :created
    field.has    :site, Plugin::Mastodon::Site, required: true
    

    def to_show
      @to_show ||= self[:title].gsub(/&(gt|lt|quot|amp);/){|m| {'gt' => '>', 'lt' => '<', 'quot' => '"', 'amp' => '&'}[$1] }.freeze
    end

    def user
      site
    end

  end
end

